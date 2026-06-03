// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $WorkoutsTable extends Workouts with TableInfo<$WorkoutsTable, Workout> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _routineIdMeta =
      const VerificationMeta('routineId');
  @override
  late final GeneratedColumn<int> routineId = GeneratedColumn<int>(
      'routineId', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumnWithTypeConverter<WorkoutState, String> state =
      GeneratedColumn<String>('state', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<WorkoutState>($WorkoutsTable.$converterstate);
  static const VerificationMeta _timeElapsedMeta =
      const VerificationMeta('timeElapsed');
  @override
  late final GeneratedColumn<int> timeElapsed = GeneratedColumn<int>(
      'timeElapsed', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _createdMeta =
      const VerificationMeta('created');
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> created =
      GeneratedColumn<String>('created', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<DateTime>($WorkoutsTable.$convertercreated);
  static const VerificationMeta _completedMeta =
      const VerificationMeta('completed');
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> completed =
      GeneratedColumn<String>('completed', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<DateTime>($WorkoutsTable.$convertercompleted);
  @override
  List<GeneratedColumn> get $columns =>
      [id, routineId, notes, title, state, timeElapsed, created, completed];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workouts';
  @override
  VerificationContext validateIntegrity(Insertable<Workout> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('routineId')) {
      context.handle(_routineIdMeta,
          routineId.isAcceptableOrUnknown(data['routineId']!, _routineIdMeta));
    } else if (isInserting) {
      context.missing(_routineIdMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    } else if (isInserting) {
      context.missing(_notesMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    context.handle(_stateMeta, const VerificationResult.success());
    if (data.containsKey('timeElapsed')) {
      context.handle(
          _timeElapsedMeta,
          timeElapsed.isAcceptableOrUnknown(
              data['timeElapsed']!, _timeElapsedMeta));
    } else if (isInserting) {
      context.missing(_timeElapsedMeta);
    }
    context.handle(_createdMeta, const VerificationResult.success());
    context.handle(_completedMeta, const VerificationResult.success());
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Workout map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Workout(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      routineId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}routineId'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      state: $WorkoutsTable.$converterstate.fromSql(attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}state'])!),
      timeElapsed: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}timeElapsed'])!,
      created: $WorkoutsTable.$convertercreated.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created'])!),
      completed: $WorkoutsTable.$convertercompleted.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}completed'])!),
    );
  }

  @override
  $WorkoutsTable createAlias(String alias) {
    return $WorkoutsTable(attachedDatabase, alias);
  }

  static TypeConverter<WorkoutState, String> $converterstate =
      const EnumNameConverter(WorkoutState.values);
  static TypeConverter<DateTime, String> $convertercreated =
      const IsoDateTimeConverter();
  static TypeConverter<DateTime, String> $convertercompleted =
      const IsoDateTimeConverter();
}

class Workout extends DataClass implements Insertable<Workout> {
  final int id;
  final int routineId;
  final String notes;
  final String title;
  final WorkoutState state;
  final int timeElapsed;
  final DateTime created;
  final DateTime completed;
  const Workout(
      {required this.id,
      required this.routineId,
      required this.notes,
      required this.title,
      required this.state,
      required this.timeElapsed,
      required this.created,
      required this.completed});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['routineId'] = Variable<int>(routineId);
    map['notes'] = Variable<String>(notes);
    map['title'] = Variable<String>(title);
    {
      map['state'] =
          Variable<String>($WorkoutsTable.$converterstate.toSql(state));
    }
    map['timeElapsed'] = Variable<int>(timeElapsed);
    {
      map['created'] =
          Variable<String>($WorkoutsTable.$convertercreated.toSql(created));
    }
    {
      map['completed'] =
          Variable<String>($WorkoutsTable.$convertercompleted.toSql(completed));
    }
    return map;
  }

  WorkoutsCompanion toCompanion(bool nullToAbsent) {
    return WorkoutsCompanion(
      id: Value(id),
      routineId: Value(routineId),
      notes: Value(notes),
      title: Value(title),
      state: Value(state),
      timeElapsed: Value(timeElapsed),
      created: Value(created),
      completed: Value(completed),
    );
  }

  factory Workout.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Workout(
      id: serializer.fromJson<int>(json['id']),
      routineId: serializer.fromJson<int>(json['routineId']),
      notes: serializer.fromJson<String>(json['notes']),
      title: serializer.fromJson<String>(json['title']),
      state: serializer.fromJson<WorkoutState>(json['state']),
      timeElapsed: serializer.fromJson<int>(json['timeElapsed']),
      created: serializer.fromJson<DateTime>(json['created']),
      completed: serializer.fromJson<DateTime>(json['completed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'routineId': serializer.toJson<int>(routineId),
      'notes': serializer.toJson<String>(notes),
      'title': serializer.toJson<String>(title),
      'state': serializer.toJson<WorkoutState>(state),
      'timeElapsed': serializer.toJson<int>(timeElapsed),
      'created': serializer.toJson<DateTime>(created),
      'completed': serializer.toJson<DateTime>(completed),
    };
  }

  Workout copyWith(
          {int? id,
          int? routineId,
          String? notes,
          String? title,
          WorkoutState? state,
          int? timeElapsed,
          DateTime? created,
          DateTime? completed}) =>
      Workout(
        id: id ?? this.id,
        routineId: routineId ?? this.routineId,
        notes: notes ?? this.notes,
        title: title ?? this.title,
        state: state ?? this.state,
        timeElapsed: timeElapsed ?? this.timeElapsed,
        created: created ?? this.created,
        completed: completed ?? this.completed,
      );
  @override
  String toString() {
    return (StringBuffer('Workout(')
          ..write('id: $id, ')
          ..write('routineId: $routineId, ')
          ..write('notes: $notes, ')
          ..write('title: $title, ')
          ..write('state: $state, ')
          ..write('timeElapsed: $timeElapsed, ')
          ..write('created: $created, ')
          ..write('completed: $completed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, routineId, notes, title, state, timeElapsed, created, completed);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Workout &&
          other.id == this.id &&
          other.routineId == this.routineId &&
          other.notes == this.notes &&
          other.title == this.title &&
          other.state == this.state &&
          other.timeElapsed == this.timeElapsed &&
          other.created == this.created &&
          other.completed == this.completed);
}

class WorkoutsCompanion extends UpdateCompanion<Workout> {
  final Value<int> id;
  final Value<int> routineId;
  final Value<String> notes;
  final Value<String> title;
  final Value<WorkoutState> state;
  final Value<int> timeElapsed;
  final Value<DateTime> created;
  final Value<DateTime> completed;
  const WorkoutsCompanion({
    this.id = const Value.absent(),
    this.routineId = const Value.absent(),
    this.notes = const Value.absent(),
    this.title = const Value.absent(),
    this.state = const Value.absent(),
    this.timeElapsed = const Value.absent(),
    this.created = const Value.absent(),
    this.completed = const Value.absent(),
  });
  WorkoutsCompanion.insert({
    this.id = const Value.absent(),
    required int routineId,
    required String notes,
    required String title,
    required WorkoutState state,
    required int timeElapsed,
    required DateTime created,
    required DateTime completed,
  })  : routineId = Value(routineId),
        notes = Value(notes),
        title = Value(title),
        state = Value(state),
        timeElapsed = Value(timeElapsed),
        created = Value(created),
        completed = Value(completed);
  static Insertable<Workout> custom({
    Expression<int>? id,
    Expression<int>? routineId,
    Expression<String>? notes,
    Expression<String>? title,
    Expression<String>? state,
    Expression<int>? timeElapsed,
    Expression<String>? created,
    Expression<String>? completed,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (routineId != null) 'routineId': routineId,
      if (notes != null) 'notes': notes,
      if (title != null) 'title': title,
      if (state != null) 'state': state,
      if (timeElapsed != null) 'timeElapsed': timeElapsed,
      if (created != null) 'created': created,
      if (completed != null) 'completed': completed,
    });
  }

  WorkoutsCompanion copyWith(
      {Value<int>? id,
      Value<int>? routineId,
      Value<String>? notes,
      Value<String>? title,
      Value<WorkoutState>? state,
      Value<int>? timeElapsed,
      Value<DateTime>? created,
      Value<DateTime>? completed}) {
    return WorkoutsCompanion(
      id: id ?? this.id,
      routineId: routineId ?? this.routineId,
      notes: notes ?? this.notes,
      title: title ?? this.title,
      state: state ?? this.state,
      timeElapsed: timeElapsed ?? this.timeElapsed,
      created: created ?? this.created,
      completed: completed ?? this.completed,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (routineId.present) {
      map['routineId'] = Variable<int>(routineId.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (state.present) {
      map['state'] =
          Variable<String>($WorkoutsTable.$converterstate.toSql(state.value));
    }
    if (timeElapsed.present) {
      map['timeElapsed'] = Variable<int>(timeElapsed.value);
    }
    if (created.present) {
      map['created'] = Variable<String>(
          $WorkoutsTable.$convertercreated.toSql(created.value));
    }
    if (completed.present) {
      map['completed'] = Variable<String>(
          $WorkoutsTable.$convertercompleted.toSql(completed.value));
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutsCompanion(')
          ..write('id: $id, ')
          ..write('routineId: $routineId, ')
          ..write('notes: $notes, ')
          ..write('title: $title, ')
          ..write('state: $state, ')
          ..write('timeElapsed: $timeElapsed, ')
          ..write('created: $created, ')
          ..write('completed: $completed')
          ..write(')'))
        .toString();
  }
}

class $ExerciseDataTable extends ExerciseData
    with TableInfo<$ExerciseDataTable, ExerciseDataDC> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExerciseDataTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _forceMeta = const VerificationMeta('force');
  @override
  late final GeneratedColumnWithTypeConverter<Force?, String> force =
      GeneratedColumn<String>('force', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<Force?>($ExerciseDataTable.$converterforcen);
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumnWithTypeConverter<Level, String> level =
      GeneratedColumn<String>('level', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<Level>($ExerciseDataTable.$converterlevel);
  static const VerificationMeta _mechanicMeta =
      const VerificationMeta('mechanic');
  @override
  late final GeneratedColumnWithTypeConverter<Mechanic?, String> mechanic =
      GeneratedColumn<String>('mechanic', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<Mechanic?>($ExerciseDataTable.$convertermechanicn);
  static const VerificationMeta _equipmentMeta =
      const VerificationMeta('equipment');
  @override
  late final GeneratedColumnWithTypeConverter<Equipment?, String> equipment =
      GeneratedColumn<String>('equipment', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<Equipment?>($ExerciseDataTable.$converterequipmentn);
  static const VerificationMeta _primaryMusclesMeta =
      const VerificationMeta('primaryMuscles');
  @override
  late final GeneratedColumnWithTypeConverter<List<Muscle>, String>
      primaryMuscles = GeneratedColumn<String>(
              'primaryMuscles', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<List<Muscle>>(
              $ExerciseDataTable.$converterprimaryMuscles);
  static const VerificationMeta _secondaryMusclesMeta =
      const VerificationMeta('secondaryMuscles');
  @override
  late final GeneratedColumnWithTypeConverter<List<Muscle>, String>
      secondaryMuscles = GeneratedColumn<String>(
              'secondaryMuscles', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<List<Muscle>>(
              $ExerciseDataTable.$convertersecondaryMuscles);
  static const VerificationMeta _instructionsMeta =
      const VerificationMeta('instructions');
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String>
      instructions = GeneratedColumn<String>('instructions', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<List<String>>(
              $ExerciseDataTable.$converterinstructions);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumnWithTypeConverter<Category, String> category =
      GeneratedColumn<String>('category', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<Category>($ExerciseDataTable.$convertercategory);
  static const VerificationMeta _imagesMeta = const VerificationMeta('images');
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String> images =
      GeneratedColumn<String>('images', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<List<String>>($ExerciseDataTable.$converterimages);
  static const VerificationMeta _isCustomExerciseMeta =
      const VerificationMeta('isCustomExercise');
  @override
  late final GeneratedColumn<bool> isCustomExercise = GeneratedColumn<bool>(
      'isCustomExercise', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("isCustomExercise" IN (0, 1))'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        force,
        level,
        mechanic,
        equipment,
        primaryMuscles,
        secondaryMuscles,
        instructions,
        category,
        images,
        isCustomExercise
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exercise_data';
  @override
  VerificationContext validateIntegrity(Insertable<ExerciseDataDC> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    context.handle(_forceMeta, const VerificationResult.success());
    context.handle(_levelMeta, const VerificationResult.success());
    context.handle(_mechanicMeta, const VerificationResult.success());
    context.handle(_equipmentMeta, const VerificationResult.success());
    context.handle(_primaryMusclesMeta, const VerificationResult.success());
    context.handle(_secondaryMusclesMeta, const VerificationResult.success());
    context.handle(_instructionsMeta, const VerificationResult.success());
    context.handle(_categoryMeta, const VerificationResult.success());
    context.handle(_imagesMeta, const VerificationResult.success());
    if (data.containsKey('isCustomExercise')) {
      context.handle(
          _isCustomExerciseMeta,
          isCustomExercise.isAcceptableOrUnknown(
              data['isCustomExercise']!, _isCustomExerciseMeta));
    } else if (isInserting) {
      context.missing(_isCustomExerciseMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExerciseDataDC map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExerciseDataDC(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      force: $ExerciseDataTable.$converterforcen.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}force'])),
      level: $ExerciseDataTable.$converterlevel.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}level'])!),
      mechanic: $ExerciseDataTable.$convertermechanicn.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}mechanic'])),
      equipment: $ExerciseDataTable.$converterequipmentn.fromSql(
          attachedDatabase.typeMapping
              .read(DriftSqlType.string, data['${effectivePrefix}equipment'])),
      primaryMuscles: $ExerciseDataTable.$converterprimaryMuscles.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}primaryMuscles'])!),
      secondaryMuscles: $ExerciseDataTable.$convertersecondaryMuscles.fromSql(
          attachedDatabase.typeMapping.read(DriftSqlType.string,
              data['${effectivePrefix}secondaryMuscles'])!),
      instructions: $ExerciseDataTable.$converterinstructions.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}instructions'])!),
      category: $ExerciseDataTable.$convertercategory.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!),
      images: $ExerciseDataTable.$converterimages.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}images'])!),
      isCustomExercise: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}isCustomExercise'])!,
    );
  }

  @override
  $ExerciseDataTable createAlias(String alias) {
    return $ExerciseDataTable(attachedDatabase, alias);
  }

  static TypeConverter<Force, String> $converterforce =
      const EnumNameConverter(Force.values);
  static TypeConverter<Force?, String?> $converterforcen =
      NullAwareTypeConverter.wrap($converterforce);
  static TypeConverter<Level, String> $converterlevel =
      const EnumNameConverter(Level.values);
  static TypeConverter<Mechanic, String> $convertermechanic =
      const EnumNameConverter(Mechanic.values);
  static TypeConverter<Mechanic?, String?> $convertermechanicn =
      NullAwareTypeConverter.wrap($convertermechanic);
  static TypeConverter<Equipment, String> $converterequipment =
      const EnumNameConverter(Equipment.values);
  static TypeConverter<Equipment?, String?> $converterequipmentn =
      NullAwareTypeConverter.wrap($converterequipment);
  static TypeConverter<List<Muscle>, String> $converterprimaryMuscles =
      const MuscleListConverter();
  static TypeConverter<List<Muscle>, String> $convertersecondaryMuscles =
      const MuscleListConverter();
  static TypeConverter<List<String>, String> $converterinstructions =
      const StringListConverter();
  static TypeConverter<Category, String> $convertercategory =
      const EnumNameConverter(Category.values);
  static TypeConverter<List<String>, String> $converterimages =
      const StringListConverter();
}

class ExerciseDataDC extends DataClass implements Insertable<ExerciseDataDC> {
  final String id;
  final String name;
  final Force? force;
  final Level level;
  final Mechanic? mechanic;
  final Equipment? equipment;
  final List<Muscle> primaryMuscles;
  final List<Muscle> secondaryMuscles;
  final List<String> instructions;
  final Category category;
  final List<String> images;
  final bool isCustomExercise;
  const ExerciseDataDC(
      {required this.id,
      required this.name,
      this.force,
      required this.level,
      this.mechanic,
      this.equipment,
      required this.primaryMuscles,
      required this.secondaryMuscles,
      required this.instructions,
      required this.category,
      required this.images,
      required this.isCustomExercise});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || force != null) {
      map['force'] =
          Variable<String>($ExerciseDataTable.$converterforcen.toSql(force));
    }
    {
      map['level'] =
          Variable<String>($ExerciseDataTable.$converterlevel.toSql(level));
    }
    if (!nullToAbsent || mechanic != null) {
      map['mechanic'] = Variable<String>(
          $ExerciseDataTable.$convertermechanicn.toSql(mechanic));
    }
    if (!nullToAbsent || equipment != null) {
      map['equipment'] = Variable<String>(
          $ExerciseDataTable.$converterequipmentn.toSql(equipment));
    }
    {
      map['primaryMuscles'] = Variable<String>(
          $ExerciseDataTable.$converterprimaryMuscles.toSql(primaryMuscles));
    }
    {
      map['secondaryMuscles'] = Variable<String>($ExerciseDataTable
          .$convertersecondaryMuscles
          .toSql(secondaryMuscles));
    }
    {
      map['instructions'] = Variable<String>(
          $ExerciseDataTable.$converterinstructions.toSql(instructions));
    }
    {
      map['category'] = Variable<String>(
          $ExerciseDataTable.$convertercategory.toSql(category));
    }
    {
      map['images'] =
          Variable<String>($ExerciseDataTable.$converterimages.toSql(images));
    }
    map['isCustomExercise'] = Variable<bool>(isCustomExercise);
    return map;
  }

  ExerciseDataCompanion toCompanion(bool nullToAbsent) {
    return ExerciseDataCompanion(
      id: Value(id),
      name: Value(name),
      force:
          force == null && nullToAbsent ? const Value.absent() : Value(force),
      level: Value(level),
      mechanic: mechanic == null && nullToAbsent
          ? const Value.absent()
          : Value(mechanic),
      equipment: equipment == null && nullToAbsent
          ? const Value.absent()
          : Value(equipment),
      primaryMuscles: Value(primaryMuscles),
      secondaryMuscles: Value(secondaryMuscles),
      instructions: Value(instructions),
      category: Value(category),
      images: Value(images),
      isCustomExercise: Value(isCustomExercise),
    );
  }

  factory ExerciseDataDC.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExerciseDataDC(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      force: serializer.fromJson<Force?>(json['force']),
      level: serializer.fromJson<Level>(json['level']),
      mechanic: serializer.fromJson<Mechanic?>(json['mechanic']),
      equipment: serializer.fromJson<Equipment?>(json['equipment']),
      primaryMuscles: serializer.fromJson<List<Muscle>>(json['primaryMuscles']),
      secondaryMuscles:
          serializer.fromJson<List<Muscle>>(json['secondaryMuscles']),
      instructions: serializer.fromJson<List<String>>(json['instructions']),
      category: serializer.fromJson<Category>(json['category']),
      images: serializer.fromJson<List<String>>(json['images']),
      isCustomExercise: serializer.fromJson<bool>(json['isCustomExercise']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'force': serializer.toJson<Force?>(force),
      'level': serializer.toJson<Level>(level),
      'mechanic': serializer.toJson<Mechanic?>(mechanic),
      'equipment': serializer.toJson<Equipment?>(equipment),
      'primaryMuscles': serializer.toJson<List<Muscle>>(primaryMuscles),
      'secondaryMuscles': serializer.toJson<List<Muscle>>(secondaryMuscles),
      'instructions': serializer.toJson<List<String>>(instructions),
      'category': serializer.toJson<Category>(category),
      'images': serializer.toJson<List<String>>(images),
      'isCustomExercise': serializer.toJson<bool>(isCustomExercise),
    };
  }

  ExerciseDataDC copyWith(
          {String? id,
          String? name,
          Value<Force?> force = const Value.absent(),
          Level? level,
          Value<Mechanic?> mechanic = const Value.absent(),
          Value<Equipment?> equipment = const Value.absent(),
          List<Muscle>? primaryMuscles,
          List<Muscle>? secondaryMuscles,
          List<String>? instructions,
          Category? category,
          List<String>? images,
          bool? isCustomExercise}) =>
      ExerciseDataDC(
        id: id ?? this.id,
        name: name ?? this.name,
        force: force.present ? force.value : this.force,
        level: level ?? this.level,
        mechanic: mechanic.present ? mechanic.value : this.mechanic,
        equipment: equipment.present ? equipment.value : this.equipment,
        primaryMuscles: primaryMuscles ?? this.primaryMuscles,
        secondaryMuscles: secondaryMuscles ?? this.secondaryMuscles,
        instructions: instructions ?? this.instructions,
        category: category ?? this.category,
        images: images ?? this.images,
        isCustomExercise: isCustomExercise ?? this.isCustomExercise,
      );
  @override
  String toString() {
    return (StringBuffer('ExerciseDataDC(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('force: $force, ')
          ..write('level: $level, ')
          ..write('mechanic: $mechanic, ')
          ..write('equipment: $equipment, ')
          ..write('primaryMuscles: $primaryMuscles, ')
          ..write('secondaryMuscles: $secondaryMuscles, ')
          ..write('instructions: $instructions, ')
          ..write('category: $category, ')
          ..write('images: $images, ')
          ..write('isCustomExercise: $isCustomExercise')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      name,
      force,
      level,
      mechanic,
      equipment,
      primaryMuscles,
      secondaryMuscles,
      instructions,
      category,
      images,
      isCustomExercise);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExerciseDataDC &&
          other.id == this.id &&
          other.name == this.name &&
          other.force == this.force &&
          other.level == this.level &&
          other.mechanic == this.mechanic &&
          other.equipment == this.equipment &&
          other.primaryMuscles == this.primaryMuscles &&
          other.secondaryMuscles == this.secondaryMuscles &&
          other.instructions == this.instructions &&
          other.category == this.category &&
          other.images == this.images &&
          other.isCustomExercise == this.isCustomExercise);
}

class ExerciseDataCompanion extends UpdateCompanion<ExerciseDataDC> {
  final Value<String> id;
  final Value<String> name;
  final Value<Force?> force;
  final Value<Level> level;
  final Value<Mechanic?> mechanic;
  final Value<Equipment?> equipment;
  final Value<List<Muscle>> primaryMuscles;
  final Value<List<Muscle>> secondaryMuscles;
  final Value<List<String>> instructions;
  final Value<Category> category;
  final Value<List<String>> images;
  final Value<bool> isCustomExercise;
  final Value<int> rowid;
  const ExerciseDataCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.force = const Value.absent(),
    this.level = const Value.absent(),
    this.mechanic = const Value.absent(),
    this.equipment = const Value.absent(),
    this.primaryMuscles = const Value.absent(),
    this.secondaryMuscles = const Value.absent(),
    this.instructions = const Value.absent(),
    this.category = const Value.absent(),
    this.images = const Value.absent(),
    this.isCustomExercise = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExerciseDataCompanion.insert({
    required String id,
    required String name,
    this.force = const Value.absent(),
    required Level level,
    this.mechanic = const Value.absent(),
    this.equipment = const Value.absent(),
    required List<Muscle> primaryMuscles,
    required List<Muscle> secondaryMuscles,
    required List<String> instructions,
    required Category category,
    required List<String> images,
    required bool isCustomExercise,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        level = Value(level),
        primaryMuscles = Value(primaryMuscles),
        secondaryMuscles = Value(secondaryMuscles),
        instructions = Value(instructions),
        category = Value(category),
        images = Value(images),
        isCustomExercise = Value(isCustomExercise);
  static Insertable<ExerciseDataDC> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? force,
    Expression<String>? level,
    Expression<String>? mechanic,
    Expression<String>? equipment,
    Expression<String>? primaryMuscles,
    Expression<String>? secondaryMuscles,
    Expression<String>? instructions,
    Expression<String>? category,
    Expression<String>? images,
    Expression<bool>? isCustomExercise,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (force != null) 'force': force,
      if (level != null) 'level': level,
      if (mechanic != null) 'mechanic': mechanic,
      if (equipment != null) 'equipment': equipment,
      if (primaryMuscles != null) 'primaryMuscles': primaryMuscles,
      if (secondaryMuscles != null) 'secondaryMuscles': secondaryMuscles,
      if (instructions != null) 'instructions': instructions,
      if (category != null) 'category': category,
      if (images != null) 'images': images,
      if (isCustomExercise != null) 'isCustomExercise': isCustomExercise,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExerciseDataCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<Force?>? force,
      Value<Level>? level,
      Value<Mechanic?>? mechanic,
      Value<Equipment?>? equipment,
      Value<List<Muscle>>? primaryMuscles,
      Value<List<Muscle>>? secondaryMuscles,
      Value<List<String>>? instructions,
      Value<Category>? category,
      Value<List<String>>? images,
      Value<bool>? isCustomExercise,
      Value<int>? rowid}) {
    return ExerciseDataCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      force: force ?? this.force,
      level: level ?? this.level,
      mechanic: mechanic ?? this.mechanic,
      equipment: equipment ?? this.equipment,
      primaryMuscles: primaryMuscles ?? this.primaryMuscles,
      secondaryMuscles: secondaryMuscles ?? this.secondaryMuscles,
      instructions: instructions ?? this.instructions,
      category: category ?? this.category,
      images: images ?? this.images,
      isCustomExercise: isCustomExercise ?? this.isCustomExercise,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (force.present) {
      map['force'] = Variable<String>(
          $ExerciseDataTable.$converterforcen.toSql(force.value));
    }
    if (level.present) {
      map['level'] = Variable<String>(
          $ExerciseDataTable.$converterlevel.toSql(level.value));
    }
    if (mechanic.present) {
      map['mechanic'] = Variable<String>(
          $ExerciseDataTable.$convertermechanicn.toSql(mechanic.value));
    }
    if (equipment.present) {
      map['equipment'] = Variable<String>(
          $ExerciseDataTable.$converterequipmentn.toSql(equipment.value));
    }
    if (primaryMuscles.present) {
      map['primaryMuscles'] = Variable<String>($ExerciseDataTable
          .$converterprimaryMuscles
          .toSql(primaryMuscles.value));
    }
    if (secondaryMuscles.present) {
      map['secondaryMuscles'] = Variable<String>($ExerciseDataTable
          .$convertersecondaryMuscles
          .toSql(secondaryMuscles.value));
    }
    if (instructions.present) {
      map['instructions'] = Variable<String>(
          $ExerciseDataTable.$converterinstructions.toSql(instructions.value));
    }
    if (category.present) {
      map['category'] = Variable<String>(
          $ExerciseDataTable.$convertercategory.toSql(category.value));
    }
    if (images.present) {
      map['images'] = Variable<String>(
          $ExerciseDataTable.$converterimages.toSql(images.value));
    }
    if (isCustomExercise.present) {
      map['isCustomExercise'] = Variable<bool>(isCustomExercise.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseDataCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('force: $force, ')
          ..write('level: $level, ')
          ..write('mechanic: $mechanic, ')
          ..write('equipment: $equipment, ')
          ..write('primaryMuscles: $primaryMuscles, ')
          ..write('secondaryMuscles: $secondaryMuscles, ')
          ..write('instructions: $instructions, ')
          ..write('category: $category, ')
          ..write('images: $images, ')
          ..write('isCustomExercise: $isCustomExercise, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExercisesTable extends Exercises
    with TableInfo<$ExercisesTable, Exercise> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExercisesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _exerciseDataIdMeta =
      const VerificationMeta('exerciseDataId');
  @override
  late final GeneratedColumn<String> exerciseDataId = GeneratedColumn<String>(
      'exerciseDataId', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _setModeMeta =
      const VerificationMeta('setMode');
  @override
  late final GeneratedColumnWithTypeConverter<SetMode, String> setMode =
      GeneratedColumn<String>('setMode', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<SetMode>($ExercisesTable.$convertersetMode);
  static const VerificationMeta _restTimeMeta =
      const VerificationMeta('restTime');
  @override
  late final GeneratedColumn<int> restTime = GeneratedColumn<int>(
      'restTime', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _positionMeta =
      const VerificationMeta('position');
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
      'position', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _supersetIdMeta =
      const VerificationMeta('supersetId');
  @override
  late final GeneratedColumn<int> supersetId = GeneratedColumn<int>(
      'supersetId', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _workoutIdMeta =
      const VerificationMeta('workoutId');
  @override
  late final GeneratedColumn<int> workoutId = GeneratedColumn<int>(
      'workoutId', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        exerciseDataId,
        notes,
        setMode,
        restTime,
        position,
        supersetId,
        workoutId
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exercises';
  @override
  VerificationContext validateIntegrity(Insertable<Exercise> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('exerciseDataId')) {
      context.handle(
          _exerciseDataIdMeta,
          exerciseDataId.isAcceptableOrUnknown(
              data['exerciseDataId']!, _exerciseDataIdMeta));
    } else if (isInserting) {
      context.missing(_exerciseDataIdMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    } else if (isInserting) {
      context.missing(_notesMeta);
    }
    context.handle(_setModeMeta, const VerificationResult.success());
    if (data.containsKey('restTime')) {
      context.handle(_restTimeMeta,
          restTime.isAcceptableOrUnknown(data['restTime']!, _restTimeMeta));
    } else if (isInserting) {
      context.missing(_restTimeMeta);
    }
    if (data.containsKey('position')) {
      context.handle(_positionMeta,
          position.isAcceptableOrUnknown(data['position']!, _positionMeta));
    }
    if (data.containsKey('supersetId')) {
      context.handle(
          _supersetIdMeta,
          supersetId.isAcceptableOrUnknown(
              data['supersetId']!, _supersetIdMeta));
    }
    if (data.containsKey('workoutId')) {
      context.handle(_workoutIdMeta,
          workoutId.isAcceptableOrUnknown(data['workoutId']!, _workoutIdMeta));
    } else if (isInserting) {
      context.missing(_workoutIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Exercise map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Exercise(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      exerciseDataId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}exerciseDataId'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes'])!,
      setMode: $ExercisesTable.$convertersetMode.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}setMode'])!),
      restTime: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}restTime'])!,
      position: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}position'])!,
      supersetId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}supersetId']),
      workoutId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}workoutId'])!,
    );
  }

  @override
  $ExercisesTable createAlias(String alias) {
    return $ExercisesTable(attachedDatabase, alias);
  }

  static TypeConverter<SetMode, String> $convertersetMode =
      const EnumNameConverter(SetMode.values);
}

class Exercise extends DataClass implements Insertable<Exercise> {
  final int id;
  final String exerciseDataId;
  final String notes;
  final SetMode setMode;
  final int restTime;
  final int position;
  final int? supersetId;
  final int workoutId;
  const Exercise(
      {required this.id,
      required this.exerciseDataId,
      required this.notes,
      required this.setMode,
      required this.restTime,
      required this.position,
      this.supersetId,
      required this.workoutId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['exerciseDataId'] = Variable<String>(exerciseDataId);
    map['notes'] = Variable<String>(notes);
    {
      map['setMode'] =
          Variable<String>($ExercisesTable.$convertersetMode.toSql(setMode));
    }
    map['restTime'] = Variable<int>(restTime);
    map['position'] = Variable<int>(position);
    if (!nullToAbsent || supersetId != null) {
      map['supersetId'] = Variable<int>(supersetId);
    }
    map['workoutId'] = Variable<int>(workoutId);
    return map;
  }

  ExercisesCompanion toCompanion(bool nullToAbsent) {
    return ExercisesCompanion(
      id: Value(id),
      exerciseDataId: Value(exerciseDataId),
      notes: Value(notes),
      setMode: Value(setMode),
      restTime: Value(restTime),
      position: Value(position),
      supersetId: supersetId == null && nullToAbsent
          ? const Value.absent()
          : Value(supersetId),
      workoutId: Value(workoutId),
    );
  }

  factory Exercise.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Exercise(
      id: serializer.fromJson<int>(json['id']),
      exerciseDataId: serializer.fromJson<String>(json['exerciseDataId']),
      notes: serializer.fromJson<String>(json['notes']),
      setMode: serializer.fromJson<SetMode>(json['setMode']),
      restTime: serializer.fromJson<int>(json['restTime']),
      position: serializer.fromJson<int>(json['position']),
      supersetId: serializer.fromJson<int?>(json['supersetId']),
      workoutId: serializer.fromJson<int>(json['workoutId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'exerciseDataId': serializer.toJson<String>(exerciseDataId),
      'notes': serializer.toJson<String>(notes),
      'setMode': serializer.toJson<SetMode>(setMode),
      'restTime': serializer.toJson<int>(restTime),
      'position': serializer.toJson<int>(position),
      'supersetId': serializer.toJson<int?>(supersetId),
      'workoutId': serializer.toJson<int>(workoutId),
    };
  }

  Exercise copyWith(
          {int? id,
          String? exerciseDataId,
          String? notes,
          SetMode? setMode,
          int? restTime,
          int? position,
          Value<int?> supersetId = const Value.absent(),
          int? workoutId}) =>
      Exercise(
        id: id ?? this.id,
        exerciseDataId: exerciseDataId ?? this.exerciseDataId,
        notes: notes ?? this.notes,
        setMode: setMode ?? this.setMode,
        restTime: restTime ?? this.restTime,
        position: position ?? this.position,
        supersetId: supersetId.present ? supersetId.value : this.supersetId,
        workoutId: workoutId ?? this.workoutId,
      );
  @override
  String toString() {
    return (StringBuffer('Exercise(')
          ..write('id: $id, ')
          ..write('exerciseDataId: $exerciseDataId, ')
          ..write('notes: $notes, ')
          ..write('setMode: $setMode, ')
          ..write('restTime: $restTime, ')
          ..write('position: $position, ')
          ..write('supersetId: $supersetId, ')
          ..write('workoutId: $workoutId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, exerciseDataId, notes, setMode, restTime,
      position, supersetId, workoutId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Exercise &&
          other.id == this.id &&
          other.exerciseDataId == this.exerciseDataId &&
          other.notes == this.notes &&
          other.setMode == this.setMode &&
          other.restTime == this.restTime &&
          other.position == this.position &&
          other.supersetId == this.supersetId &&
          other.workoutId == this.workoutId);
}

class ExercisesCompanion extends UpdateCompanion<Exercise> {
  final Value<int> id;
  final Value<String> exerciseDataId;
  final Value<String> notes;
  final Value<SetMode> setMode;
  final Value<int> restTime;
  final Value<int> position;
  final Value<int?> supersetId;
  final Value<int> workoutId;
  const ExercisesCompanion({
    this.id = const Value.absent(),
    this.exerciseDataId = const Value.absent(),
    this.notes = const Value.absent(),
    this.setMode = const Value.absent(),
    this.restTime = const Value.absent(),
    this.position = const Value.absent(),
    this.supersetId = const Value.absent(),
    this.workoutId = const Value.absent(),
  });
  ExercisesCompanion.insert({
    this.id = const Value.absent(),
    required String exerciseDataId,
    required String notes,
    required SetMode setMode,
    required int restTime,
    this.position = const Value.absent(),
    this.supersetId = const Value.absent(),
    required int workoutId,
  })  : exerciseDataId = Value(exerciseDataId),
        notes = Value(notes),
        setMode = Value(setMode),
        restTime = Value(restTime),
        workoutId = Value(workoutId);
  static Insertable<Exercise> custom({
    Expression<int>? id,
    Expression<String>? exerciseDataId,
    Expression<String>? notes,
    Expression<String>? setMode,
    Expression<int>? restTime,
    Expression<int>? position,
    Expression<int>? supersetId,
    Expression<int>? workoutId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (exerciseDataId != null) 'exerciseDataId': exerciseDataId,
      if (notes != null) 'notes': notes,
      if (setMode != null) 'setMode': setMode,
      if (restTime != null) 'restTime': restTime,
      if (position != null) 'position': position,
      if (supersetId != null) 'supersetId': supersetId,
      if (workoutId != null) 'workoutId': workoutId,
    });
  }

  ExercisesCompanion copyWith(
      {Value<int>? id,
      Value<String>? exerciseDataId,
      Value<String>? notes,
      Value<SetMode>? setMode,
      Value<int>? restTime,
      Value<int>? position,
      Value<int?>? supersetId,
      Value<int>? workoutId}) {
    return ExercisesCompanion(
      id: id ?? this.id,
      exerciseDataId: exerciseDataId ?? this.exerciseDataId,
      notes: notes ?? this.notes,
      setMode: setMode ?? this.setMode,
      restTime: restTime ?? this.restTime,
      position: position ?? this.position,
      supersetId: supersetId ?? this.supersetId,
      workoutId: workoutId ?? this.workoutId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (exerciseDataId.present) {
      map['exerciseDataId'] = Variable<String>(exerciseDataId.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (setMode.present) {
      map['setMode'] = Variable<String>(
          $ExercisesTable.$convertersetMode.toSql(setMode.value));
    }
    if (restTime.present) {
      map['restTime'] = Variable<int>(restTime.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (supersetId.present) {
      map['supersetId'] = Variable<int>(supersetId.value);
    }
    if (workoutId.present) {
      map['workoutId'] = Variable<int>(workoutId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExercisesCompanion(')
          ..write('id: $id, ')
          ..write('exerciseDataId: $exerciseDataId, ')
          ..write('notes: $notes, ')
          ..write('setMode: $setMode, ')
          ..write('restTime: $restTime, ')
          ..write('position: $position, ')
          ..write('supersetId: $supersetId, ')
          ..write('workoutId: $workoutId')
          ..write(')'))
        .toString();
  }
}

class $SetsTable extends Sets with TableInfo<$SetsTable, WorkoutSet> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _loadMeta = const VerificationMeta('load');
  @override
  late final GeneratedColumn<double> load = GeneratedColumn<double>(
      'load', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _repsMeta = const VerificationMeta('reps');
  @override
  late final GeneratedColumn<int> reps = GeneratedColumn<int>(
      'reps', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _elapsedTimeMeta =
      const VerificationMeta('elapsedTime');
  @override
  late final GeneratedColumn<int> elapsedTime = GeneratedColumn<int>(
      'elapsedTime', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _completedMeta =
      const VerificationMeta('completed');
  @override
  late final GeneratedColumn<bool> completed = GeneratedColumn<bool>(
      'completed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("completed" IN (0, 1))'));
  static const VerificationMeta _rpeMeta = const VerificationMeta('rpe');
  @override
  late final GeneratedColumn<double> rpe = GeneratedColumn<double>(
      'rpe', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _rirMeta = const VerificationMeta('rir');
  @override
  late final GeneratedColumn<int> rir = GeneratedColumn<int>(
      'rir', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _intensityScale1Meta =
      const VerificationMeta('intensityScale1');
  @override
  late final GeneratedColumn<int> intensityScale1 = GeneratedColumn<int>(
      'intensityScale1', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _exerciseIdMeta =
      const VerificationMeta('exerciseId');
  @override
  late final GeneratedColumn<int> exerciseId = GeneratedColumn<int>(
      'exerciseId', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        load,
        reps,
        elapsedTime,
        completed,
        rpe,
        rir,
        intensityScale1,
        exerciseId
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sets';
  @override
  VerificationContext validateIntegrity(Insertable<WorkoutSet> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('load')) {
      context.handle(
          _loadMeta, load.isAcceptableOrUnknown(data['load']!, _loadMeta));
    } else if (isInserting) {
      context.missing(_loadMeta);
    }
    if (data.containsKey('reps')) {
      context.handle(
          _repsMeta, reps.isAcceptableOrUnknown(data['reps']!, _repsMeta));
    } else if (isInserting) {
      context.missing(_repsMeta);
    }
    if (data.containsKey('elapsedTime')) {
      context.handle(
          _elapsedTimeMeta,
          elapsedTime.isAcceptableOrUnknown(
              data['elapsedTime']!, _elapsedTimeMeta));
    } else if (isInserting) {
      context.missing(_elapsedTimeMeta);
    }
    if (data.containsKey('completed')) {
      context.handle(_completedMeta,
          completed.isAcceptableOrUnknown(data['completed']!, _completedMeta));
    } else if (isInserting) {
      context.missing(_completedMeta);
    }
    if (data.containsKey('rpe')) {
      context.handle(
          _rpeMeta, rpe.isAcceptableOrUnknown(data['rpe']!, _rpeMeta));
    }
    if (data.containsKey('rir')) {
      context.handle(
          _rirMeta, rir.isAcceptableOrUnknown(data['rir']!, _rirMeta));
    }
    if (data.containsKey('intensityScale1')) {
      context.handle(
          _intensityScale1Meta,
          intensityScale1.isAcceptableOrUnknown(
              data['intensityScale1']!, _intensityScale1Meta));
    }
    if (data.containsKey('exerciseId')) {
      context.handle(
          _exerciseIdMeta,
          exerciseId.isAcceptableOrUnknown(
              data['exerciseId']!, _exerciseIdMeta));
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkoutSet map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkoutSet(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      load: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}load'])!,
      reps: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}reps'])!,
      elapsedTime: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}elapsedTime'])!,
      completed: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}completed'])!,
      rpe: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}rpe']),
      rir: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}rir']),
      intensityScale1: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}intensityScale1']),
      exerciseId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}exerciseId'])!,
    );
  }

  @override
  $SetsTable createAlias(String alias) {
    return $SetsTable(attachedDatabase, alias);
  }
}

class WorkoutSet extends DataClass implements Insertable<WorkoutSet> {
  final int id;
  final double load;
  final int reps;
  final int elapsedTime;
  final bool completed;
  final double? rpe;
  final int? rir;
  final int? intensityScale1;
  final int exerciseId;
  const WorkoutSet(
      {required this.id,
      required this.load,
      required this.reps,
      required this.elapsedTime,
      required this.completed,
      this.rpe,
      this.rir,
      this.intensityScale1,
      required this.exerciseId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['load'] = Variable<double>(load);
    map['reps'] = Variable<int>(reps);
    map['elapsedTime'] = Variable<int>(elapsedTime);
    map['completed'] = Variable<bool>(completed);
    if (!nullToAbsent || rpe != null) {
      map['rpe'] = Variable<double>(rpe);
    }
    if (!nullToAbsent || rir != null) {
      map['rir'] = Variable<int>(rir);
    }
    if (!nullToAbsent || intensityScale1 != null) {
      map['intensityScale1'] = Variable<int>(intensityScale1);
    }
    map['exerciseId'] = Variable<int>(exerciseId);
    return map;
  }

  SetsCompanion toCompanion(bool nullToAbsent) {
    return SetsCompanion(
      id: Value(id),
      load: Value(load),
      reps: Value(reps),
      elapsedTime: Value(elapsedTime),
      completed: Value(completed),
      rpe: rpe == null && nullToAbsent ? const Value.absent() : Value(rpe),
      rir: rir == null && nullToAbsent ? const Value.absent() : Value(rir),
      intensityScale1: intensityScale1 == null && nullToAbsent
          ? const Value.absent()
          : Value(intensityScale1),
      exerciseId: Value(exerciseId),
    );
  }

  factory WorkoutSet.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkoutSet(
      id: serializer.fromJson<int>(json['id']),
      load: serializer.fromJson<double>(json['load']),
      reps: serializer.fromJson<int>(json['reps']),
      elapsedTime: serializer.fromJson<int>(json['elapsedTime']),
      completed: serializer.fromJson<bool>(json['completed']),
      rpe: serializer.fromJson<double?>(json['rpe']),
      rir: serializer.fromJson<int?>(json['rir']),
      intensityScale1: serializer.fromJson<int?>(json['intensityScale1']),
      exerciseId: serializer.fromJson<int>(json['exerciseId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'load': serializer.toJson<double>(load),
      'reps': serializer.toJson<int>(reps),
      'elapsedTime': serializer.toJson<int>(elapsedTime),
      'completed': serializer.toJson<bool>(completed),
      'rpe': serializer.toJson<double?>(rpe),
      'rir': serializer.toJson<int?>(rir),
      'intensityScale1': serializer.toJson<int?>(intensityScale1),
      'exerciseId': serializer.toJson<int>(exerciseId),
    };
  }

  WorkoutSet copyWith(
          {int? id,
          double? load,
          int? reps,
          int? elapsedTime,
          bool? completed,
          Value<double?> rpe = const Value.absent(),
          Value<int?> rir = const Value.absent(),
          Value<int?> intensityScale1 = const Value.absent(),
          int? exerciseId}) =>
      WorkoutSet(
        id: id ?? this.id,
        load: load ?? this.load,
        reps: reps ?? this.reps,
        elapsedTime: elapsedTime ?? this.elapsedTime,
        completed: completed ?? this.completed,
        rpe: rpe.present ? rpe.value : this.rpe,
        rir: rir.present ? rir.value : this.rir,
        intensityScale1: intensityScale1.present
            ? intensityScale1.value
            : this.intensityScale1,
        exerciseId: exerciseId ?? this.exerciseId,
      );
  @override
  String toString() {
    return (StringBuffer('WorkoutSet(')
          ..write('id: $id, ')
          ..write('load: $load, ')
          ..write('reps: $reps, ')
          ..write('elapsedTime: $elapsedTime, ')
          ..write('completed: $completed, ')
          ..write('rpe: $rpe, ')
          ..write('rir: $rir, ')
          ..write('intensityScale1: $intensityScale1, ')
          ..write('exerciseId: $exerciseId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, load, reps, elapsedTime, completed, rpe,
      rir, intensityScale1, exerciseId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkoutSet &&
          other.id == this.id &&
          other.load == this.load &&
          other.reps == this.reps &&
          other.elapsedTime == this.elapsedTime &&
          other.completed == this.completed &&
          other.rpe == this.rpe &&
          other.rir == this.rir &&
          other.intensityScale1 == this.intensityScale1 &&
          other.exerciseId == this.exerciseId);
}

class SetsCompanion extends UpdateCompanion<WorkoutSet> {
  final Value<int> id;
  final Value<double> load;
  final Value<int> reps;
  final Value<int> elapsedTime;
  final Value<bool> completed;
  final Value<double?> rpe;
  final Value<int?> rir;
  final Value<int?> intensityScale1;
  final Value<int> exerciseId;
  const SetsCompanion({
    this.id = const Value.absent(),
    this.load = const Value.absent(),
    this.reps = const Value.absent(),
    this.elapsedTime = const Value.absent(),
    this.completed = const Value.absent(),
    this.rpe = const Value.absent(),
    this.rir = const Value.absent(),
    this.intensityScale1 = const Value.absent(),
    this.exerciseId = const Value.absent(),
  });
  SetsCompanion.insert({
    this.id = const Value.absent(),
    required double load,
    required int reps,
    required int elapsedTime,
    required bool completed,
    this.rpe = const Value.absent(),
    this.rir = const Value.absent(),
    this.intensityScale1 = const Value.absent(),
    required int exerciseId,
  })  : load = Value(load),
        reps = Value(reps),
        elapsedTime = Value(elapsedTime),
        completed = Value(completed),
        exerciseId = Value(exerciseId);
  static Insertable<WorkoutSet> custom({
    Expression<int>? id,
    Expression<double>? load,
    Expression<int>? reps,
    Expression<int>? elapsedTime,
    Expression<bool>? completed,
    Expression<double>? rpe,
    Expression<int>? rir,
    Expression<int>? intensityScale1,
    Expression<int>? exerciseId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (load != null) 'load': load,
      if (reps != null) 'reps': reps,
      if (elapsedTime != null) 'elapsedTime': elapsedTime,
      if (completed != null) 'completed': completed,
      if (rpe != null) 'rpe': rpe,
      if (rir != null) 'rir': rir,
      if (intensityScale1 != null) 'intensityScale1': intensityScale1,
      if (exerciseId != null) 'exerciseId': exerciseId,
    });
  }

  SetsCompanion copyWith(
      {Value<int>? id,
      Value<double>? load,
      Value<int>? reps,
      Value<int>? elapsedTime,
      Value<bool>? completed,
      Value<double?>? rpe,
      Value<int?>? rir,
      Value<int?>? intensityScale1,
      Value<int>? exerciseId}) {
    return SetsCompanion(
      id: id ?? this.id,
      load: load ?? this.load,
      reps: reps ?? this.reps,
      elapsedTime: elapsedTime ?? this.elapsedTime,
      completed: completed ?? this.completed,
      rpe: rpe ?? this.rpe,
      rir: rir ?? this.rir,
      intensityScale1: intensityScale1 ?? this.intensityScale1,
      exerciseId: exerciseId ?? this.exerciseId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (load.present) {
      map['load'] = Variable<double>(load.value);
    }
    if (reps.present) {
      map['reps'] = Variable<int>(reps.value);
    }
    if (elapsedTime.present) {
      map['elapsedTime'] = Variable<int>(elapsedTime.value);
    }
    if (completed.present) {
      map['completed'] = Variable<bool>(completed.value);
    }
    if (rpe.present) {
      map['rpe'] = Variable<double>(rpe.value);
    }
    if (rir.present) {
      map['rir'] = Variable<int>(rir.value);
    }
    if (intensityScale1.present) {
      map['intensityScale1'] = Variable<int>(intensityScale1.value);
    }
    if (exerciseId.present) {
      map['exerciseId'] = Variable<int>(exerciseId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SetsCompanion(')
          ..write('id: $id, ')
          ..write('load: $load, ')
          ..write('reps: $reps, ')
          ..write('elapsedTime: $elapsedTime, ')
          ..write('completed: $completed, ')
          ..write('rpe: $rpe, ')
          ..write('rir: $rir, ')
          ..write('intensityScale1: $intensityScale1, ')
          ..write('exerciseId: $exerciseId')
          ..write(')'))
        .toString();
  }
}

class $BodyMeasurementsTable extends BodyMeasurements
    with TableInfo<$BodyMeasurementsTable, BodyMeasurement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BodyMeasurementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _bodyWeightMeta =
      const VerificationMeta('bodyWeight');
  @override
  late final GeneratedColumn<double> bodyWeight = GeneratedColumn<double>(
      'bodyWeight', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> date =
      GeneratedColumn<String>('date', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<DateTime>($BodyMeasurementsTable.$converterdate);
  @override
  List<GeneratedColumn> get $columns => [id, bodyWeight, date];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'body_measurements';
  @override
  VerificationContext validateIntegrity(Insertable<BodyMeasurement> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('bodyWeight')) {
      context.handle(
          _bodyWeightMeta,
          bodyWeight.isAcceptableOrUnknown(
              data['bodyWeight']!, _bodyWeightMeta));
    } else if (isInserting) {
      context.missing(_bodyWeightMeta);
    }
    context.handle(_dateMeta, const VerificationResult.success());
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BodyMeasurement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BodyMeasurement(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      bodyWeight: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}bodyWeight'])!,
      date: $BodyMeasurementsTable.$converterdate.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}date'])!),
    );
  }

  @override
  $BodyMeasurementsTable createAlias(String alias) {
    return $BodyMeasurementsTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, String> $converterdate =
      const IsoDateTimeConverter();
}

class BodyMeasurement extends DataClass implements Insertable<BodyMeasurement> {
  final int id;
  final double bodyWeight;
  final DateTime date;
  const BodyMeasurement(
      {required this.id, required this.bodyWeight, required this.date});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['bodyWeight'] = Variable<double>(bodyWeight);
    {
      map['date'] =
          Variable<String>($BodyMeasurementsTable.$converterdate.toSql(date));
    }
    return map;
  }

  BodyMeasurementsCompanion toCompanion(bool nullToAbsent) {
    return BodyMeasurementsCompanion(
      id: Value(id),
      bodyWeight: Value(bodyWeight),
      date: Value(date),
    );
  }

  factory BodyMeasurement.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BodyMeasurement(
      id: serializer.fromJson<int>(json['id']),
      bodyWeight: serializer.fromJson<double>(json['bodyWeight']),
      date: serializer.fromJson<DateTime>(json['date']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'bodyWeight': serializer.toJson<double>(bodyWeight),
      'date': serializer.toJson<DateTime>(date),
    };
  }

  BodyMeasurement copyWith({int? id, double? bodyWeight, DateTime? date}) =>
      BodyMeasurement(
        id: id ?? this.id,
        bodyWeight: bodyWeight ?? this.bodyWeight,
        date: date ?? this.date,
      );
  @override
  String toString() {
    return (StringBuffer('BodyMeasurement(')
          ..write('id: $id, ')
          ..write('bodyWeight: $bodyWeight, ')
          ..write('date: $date')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, bodyWeight, date);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BodyMeasurement &&
          other.id == this.id &&
          other.bodyWeight == this.bodyWeight &&
          other.date == this.date);
}

class BodyMeasurementsCompanion extends UpdateCompanion<BodyMeasurement> {
  final Value<int> id;
  final Value<double> bodyWeight;
  final Value<DateTime> date;
  const BodyMeasurementsCompanion({
    this.id = const Value.absent(),
    this.bodyWeight = const Value.absent(),
    this.date = const Value.absent(),
  });
  BodyMeasurementsCompanion.insert({
    this.id = const Value.absent(),
    required double bodyWeight,
    required DateTime date,
  })  : bodyWeight = Value(bodyWeight),
        date = Value(date);
  static Insertable<BodyMeasurement> custom({
    Expression<int>? id,
    Expression<double>? bodyWeight,
    Expression<String>? date,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bodyWeight != null) 'bodyWeight': bodyWeight,
      if (date != null) 'date': date,
    });
  }

  BodyMeasurementsCompanion copyWith(
      {Value<int>? id, Value<double>? bodyWeight, Value<DateTime>? date}) {
    return BodyMeasurementsCompanion(
      id: id ?? this.id,
      bodyWeight: bodyWeight ?? this.bodyWeight,
      date: date ?? this.date,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (bodyWeight.present) {
      map['bodyWeight'] = Variable<double>(bodyWeight.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(
          $BodyMeasurementsTable.$converterdate.toSql(date.value));
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BodyMeasurementsCompanion(')
          ..write('id: $id, ')
          ..write('bodyWeight: $bodyWeight, ')
          ..write('date: $date')
          ..write(')'))
        .toString();
  }
}

class $AdvancedBodyMeasurementsTable extends AdvancedBodyMeasurements
    with TableInfo<$AdvancedBodyMeasurementsTable, AdvancedBodyMeasurement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AdvancedBodyMeasurementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _bodyFatPercentageMeta =
      const VerificationMeta('bodyFatPercentage');
  @override
  late final GeneratedColumn<int> bodyFatPercentage = GeneratedColumn<int>(
      'bodyFatPercentage', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _muscleMassPercentageMeta =
      const VerificationMeta('muscleMassPercentage');
  @override
  late final GeneratedColumn<int> muscleMassPercentage = GeneratedColumn<int>(
      'muscleMassPercentage', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _neckCircumferenceMeta =
      const VerificationMeta('neckCircumference');
  @override
  late final GeneratedColumn<double> neckCircumference =
      GeneratedColumn<double>('neckCircumference', aliasedName, true,
          type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _chestCircumferenceMeta =
      const VerificationMeta('chestCircumference');
  @override
  late final GeneratedColumn<double> chestCircumference =
      GeneratedColumn<double>('chestCircumference', aliasedName, true,
          type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _waistCircumferenceMeta =
      const VerificationMeta('waistCircumference');
  @override
  late final GeneratedColumn<double> waistCircumference =
      GeneratedColumn<double>('waistCircumference', aliasedName, true,
          type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _hipCircumferenceMeta =
      const VerificationMeta('hipCircumference');
  @override
  late final GeneratedColumn<double> hipCircumference = GeneratedColumn<double>(
      'hipCircumference', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _bicepLeftMeta =
      const VerificationMeta('bicepLeft');
  @override
  late final GeneratedColumn<double> bicepLeft = GeneratedColumn<double>(
      'bicepLeft', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _bicepRightMeta =
      const VerificationMeta('bicepRight');
  @override
  late final GeneratedColumn<double> bicepRight = GeneratedColumn<double>(
      'bicepRight', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _thighLeftMeta =
      const VerificationMeta('thighLeft');
  @override
  late final GeneratedColumn<double> thighLeft = GeneratedColumn<double>(
      'thighLeft', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _thighRightMeta =
      const VerificationMeta('thighRight');
  @override
  late final GeneratedColumn<double> thighRight = GeneratedColumn<double>(
      'thighRight', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _calfLeftMeta =
      const VerificationMeta('calfLeft');
  @override
  late final GeneratedColumn<double> calfLeft = GeneratedColumn<double>(
      'calfLeft', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _calfRightMeta =
      const VerificationMeta('calfRight');
  @override
  late final GeneratedColumn<double> calfRight = GeneratedColumn<double>(
      'calfRight', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> date =
      GeneratedColumn<String>('date', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<DateTime>(
              $AdvancedBodyMeasurementsTable.$converterdate);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        bodyFatPercentage,
        muscleMassPercentage,
        neckCircumference,
        chestCircumference,
        waistCircumference,
        hipCircumference,
        bicepLeft,
        bicepRight,
        thighLeft,
        thighRight,
        calfLeft,
        calfRight,
        date
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'advanced_body_measurements';
  @override
  VerificationContext validateIntegrity(
      Insertable<AdvancedBodyMeasurement> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('bodyFatPercentage')) {
      context.handle(
          _bodyFatPercentageMeta,
          bodyFatPercentage.isAcceptableOrUnknown(
              data['bodyFatPercentage']!, _bodyFatPercentageMeta));
    }
    if (data.containsKey('muscleMassPercentage')) {
      context.handle(
          _muscleMassPercentageMeta,
          muscleMassPercentage.isAcceptableOrUnknown(
              data['muscleMassPercentage']!, _muscleMassPercentageMeta));
    }
    if (data.containsKey('neckCircumference')) {
      context.handle(
          _neckCircumferenceMeta,
          neckCircumference.isAcceptableOrUnknown(
              data['neckCircumference']!, _neckCircumferenceMeta));
    }
    if (data.containsKey('chestCircumference')) {
      context.handle(
          _chestCircumferenceMeta,
          chestCircumference.isAcceptableOrUnknown(
              data['chestCircumference']!, _chestCircumferenceMeta));
    }
    if (data.containsKey('waistCircumference')) {
      context.handle(
          _waistCircumferenceMeta,
          waistCircumference.isAcceptableOrUnknown(
              data['waistCircumference']!, _waistCircumferenceMeta));
    }
    if (data.containsKey('hipCircumference')) {
      context.handle(
          _hipCircumferenceMeta,
          hipCircumference.isAcceptableOrUnknown(
              data['hipCircumference']!, _hipCircumferenceMeta));
    }
    if (data.containsKey('bicepLeft')) {
      context.handle(_bicepLeftMeta,
          bicepLeft.isAcceptableOrUnknown(data['bicepLeft']!, _bicepLeftMeta));
    }
    if (data.containsKey('bicepRight')) {
      context.handle(
          _bicepRightMeta,
          bicepRight.isAcceptableOrUnknown(
              data['bicepRight']!, _bicepRightMeta));
    }
    if (data.containsKey('thighLeft')) {
      context.handle(_thighLeftMeta,
          thighLeft.isAcceptableOrUnknown(data['thighLeft']!, _thighLeftMeta));
    }
    if (data.containsKey('thighRight')) {
      context.handle(
          _thighRightMeta,
          thighRight.isAcceptableOrUnknown(
              data['thighRight']!, _thighRightMeta));
    }
    if (data.containsKey('calfLeft')) {
      context.handle(_calfLeftMeta,
          calfLeft.isAcceptableOrUnknown(data['calfLeft']!, _calfLeftMeta));
    }
    if (data.containsKey('calfRight')) {
      context.handle(_calfRightMeta,
          calfRight.isAcceptableOrUnknown(data['calfRight']!, _calfRightMeta));
    }
    context.handle(_dateMeta, const VerificationResult.success());
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AdvancedBodyMeasurement map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AdvancedBodyMeasurement(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      bodyFatPercentage: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}bodyFatPercentage']),
      muscleMassPercentage: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}muscleMassPercentage']),
      neckCircumference: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}neckCircumference']),
      chestCircumference: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}chestCircumference']),
      waistCircumference: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}waistCircumference']),
      hipCircumference: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}hipCircumference']),
      bicepLeft: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}bicepLeft']),
      bicepRight: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}bicepRight']),
      thighLeft: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}thighLeft']),
      thighRight: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}thighRight']),
      calfLeft: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}calfLeft']),
      calfRight: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}calfRight']),
      date: $AdvancedBodyMeasurementsTable.$converterdate.fromSql(
          attachedDatabase.typeMapping
              .read(DriftSqlType.string, data['${effectivePrefix}date'])!),
    );
  }

  @override
  $AdvancedBodyMeasurementsTable createAlias(String alias) {
    return $AdvancedBodyMeasurementsTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, String> $converterdate =
      const IsoDateTimeConverter();
}

class AdvancedBodyMeasurement extends DataClass
    implements Insertable<AdvancedBodyMeasurement> {
  final int id;
  final int? bodyFatPercentage;
  final int? muscleMassPercentage;
  final double? neckCircumference;
  final double? chestCircumference;
  final double? waistCircumference;
  final double? hipCircumference;
  final double? bicepLeft;
  final double? bicepRight;
  final double? thighLeft;
  final double? thighRight;
  final double? calfLeft;
  final double? calfRight;
  final DateTime date;
  const AdvancedBodyMeasurement(
      {required this.id,
      this.bodyFatPercentage,
      this.muscleMassPercentage,
      this.neckCircumference,
      this.chestCircumference,
      this.waistCircumference,
      this.hipCircumference,
      this.bicepLeft,
      this.bicepRight,
      this.thighLeft,
      this.thighRight,
      this.calfLeft,
      this.calfRight,
      required this.date});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || bodyFatPercentage != null) {
      map['bodyFatPercentage'] = Variable<int>(bodyFatPercentage);
    }
    if (!nullToAbsent || muscleMassPercentage != null) {
      map['muscleMassPercentage'] = Variable<int>(muscleMassPercentage);
    }
    if (!nullToAbsent || neckCircumference != null) {
      map['neckCircumference'] = Variable<double>(neckCircumference);
    }
    if (!nullToAbsent || chestCircumference != null) {
      map['chestCircumference'] = Variable<double>(chestCircumference);
    }
    if (!nullToAbsent || waistCircumference != null) {
      map['waistCircumference'] = Variable<double>(waistCircumference);
    }
    if (!nullToAbsent || hipCircumference != null) {
      map['hipCircumference'] = Variable<double>(hipCircumference);
    }
    if (!nullToAbsent || bicepLeft != null) {
      map['bicepLeft'] = Variable<double>(bicepLeft);
    }
    if (!nullToAbsent || bicepRight != null) {
      map['bicepRight'] = Variable<double>(bicepRight);
    }
    if (!nullToAbsent || thighLeft != null) {
      map['thighLeft'] = Variable<double>(thighLeft);
    }
    if (!nullToAbsent || thighRight != null) {
      map['thighRight'] = Variable<double>(thighRight);
    }
    if (!nullToAbsent || calfLeft != null) {
      map['calfLeft'] = Variable<double>(calfLeft);
    }
    if (!nullToAbsent || calfRight != null) {
      map['calfRight'] = Variable<double>(calfRight);
    }
    {
      map['date'] = Variable<String>(
          $AdvancedBodyMeasurementsTable.$converterdate.toSql(date));
    }
    return map;
  }

  AdvancedBodyMeasurementsCompanion toCompanion(bool nullToAbsent) {
    return AdvancedBodyMeasurementsCompanion(
      id: Value(id),
      bodyFatPercentage: bodyFatPercentage == null && nullToAbsent
          ? const Value.absent()
          : Value(bodyFatPercentage),
      muscleMassPercentage: muscleMassPercentage == null && nullToAbsent
          ? const Value.absent()
          : Value(muscleMassPercentage),
      neckCircumference: neckCircumference == null && nullToAbsent
          ? const Value.absent()
          : Value(neckCircumference),
      chestCircumference: chestCircumference == null && nullToAbsent
          ? const Value.absent()
          : Value(chestCircumference),
      waistCircumference: waistCircumference == null && nullToAbsent
          ? const Value.absent()
          : Value(waistCircumference),
      hipCircumference: hipCircumference == null && nullToAbsent
          ? const Value.absent()
          : Value(hipCircumference),
      bicepLeft: bicepLeft == null && nullToAbsent
          ? const Value.absent()
          : Value(bicepLeft),
      bicepRight: bicepRight == null && nullToAbsent
          ? const Value.absent()
          : Value(bicepRight),
      thighLeft: thighLeft == null && nullToAbsent
          ? const Value.absent()
          : Value(thighLeft),
      thighRight: thighRight == null && nullToAbsent
          ? const Value.absent()
          : Value(thighRight),
      calfLeft: calfLeft == null && nullToAbsent
          ? const Value.absent()
          : Value(calfLeft),
      calfRight: calfRight == null && nullToAbsent
          ? const Value.absent()
          : Value(calfRight),
      date: Value(date),
    );
  }

  factory AdvancedBodyMeasurement.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AdvancedBodyMeasurement(
      id: serializer.fromJson<int>(json['id']),
      bodyFatPercentage: serializer.fromJson<int?>(json['bodyFatPercentage']),
      muscleMassPercentage:
          serializer.fromJson<int?>(json['muscleMassPercentage']),
      neckCircumference:
          serializer.fromJson<double?>(json['neckCircumference']),
      chestCircumference:
          serializer.fromJson<double?>(json['chestCircumference']),
      waistCircumference:
          serializer.fromJson<double?>(json['waistCircumference']),
      hipCircumference: serializer.fromJson<double?>(json['hipCircumference']),
      bicepLeft: serializer.fromJson<double?>(json['bicepLeft']),
      bicepRight: serializer.fromJson<double?>(json['bicepRight']),
      thighLeft: serializer.fromJson<double?>(json['thighLeft']),
      thighRight: serializer.fromJson<double?>(json['thighRight']),
      calfLeft: serializer.fromJson<double?>(json['calfLeft']),
      calfRight: serializer.fromJson<double?>(json['calfRight']),
      date: serializer.fromJson<DateTime>(json['date']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'bodyFatPercentage': serializer.toJson<int?>(bodyFatPercentage),
      'muscleMassPercentage': serializer.toJson<int?>(muscleMassPercentage),
      'neckCircumference': serializer.toJson<double?>(neckCircumference),
      'chestCircumference': serializer.toJson<double?>(chestCircumference),
      'waistCircumference': serializer.toJson<double?>(waistCircumference),
      'hipCircumference': serializer.toJson<double?>(hipCircumference),
      'bicepLeft': serializer.toJson<double?>(bicepLeft),
      'bicepRight': serializer.toJson<double?>(bicepRight),
      'thighLeft': serializer.toJson<double?>(thighLeft),
      'thighRight': serializer.toJson<double?>(thighRight),
      'calfLeft': serializer.toJson<double?>(calfLeft),
      'calfRight': serializer.toJson<double?>(calfRight),
      'date': serializer.toJson<DateTime>(date),
    };
  }

  AdvancedBodyMeasurement copyWith(
          {int? id,
          Value<int?> bodyFatPercentage = const Value.absent(),
          Value<int?> muscleMassPercentage = const Value.absent(),
          Value<double?> neckCircumference = const Value.absent(),
          Value<double?> chestCircumference = const Value.absent(),
          Value<double?> waistCircumference = const Value.absent(),
          Value<double?> hipCircumference = const Value.absent(),
          Value<double?> bicepLeft = const Value.absent(),
          Value<double?> bicepRight = const Value.absent(),
          Value<double?> thighLeft = const Value.absent(),
          Value<double?> thighRight = const Value.absent(),
          Value<double?> calfLeft = const Value.absent(),
          Value<double?> calfRight = const Value.absent(),
          DateTime? date}) =>
      AdvancedBodyMeasurement(
        id: id ?? this.id,
        bodyFatPercentage: bodyFatPercentage.present
            ? bodyFatPercentage.value
            : this.bodyFatPercentage,
        muscleMassPercentage: muscleMassPercentage.present
            ? muscleMassPercentage.value
            : this.muscleMassPercentage,
        neckCircumference: neckCircumference.present
            ? neckCircumference.value
            : this.neckCircumference,
        chestCircumference: chestCircumference.present
            ? chestCircumference.value
            : this.chestCircumference,
        waistCircumference: waistCircumference.present
            ? waistCircumference.value
            : this.waistCircumference,
        hipCircumference: hipCircumference.present
            ? hipCircumference.value
            : this.hipCircumference,
        bicepLeft: bicepLeft.present ? bicepLeft.value : this.bicepLeft,
        bicepRight: bicepRight.present ? bicepRight.value : this.bicepRight,
        thighLeft: thighLeft.present ? thighLeft.value : this.thighLeft,
        thighRight: thighRight.present ? thighRight.value : this.thighRight,
        calfLeft: calfLeft.present ? calfLeft.value : this.calfLeft,
        calfRight: calfRight.present ? calfRight.value : this.calfRight,
        date: date ?? this.date,
      );
  @override
  String toString() {
    return (StringBuffer('AdvancedBodyMeasurement(')
          ..write('id: $id, ')
          ..write('bodyFatPercentage: $bodyFatPercentage, ')
          ..write('muscleMassPercentage: $muscleMassPercentage, ')
          ..write('neckCircumference: $neckCircumference, ')
          ..write('chestCircumference: $chestCircumference, ')
          ..write('waistCircumference: $waistCircumference, ')
          ..write('hipCircumference: $hipCircumference, ')
          ..write('bicepLeft: $bicepLeft, ')
          ..write('bicepRight: $bicepRight, ')
          ..write('thighLeft: $thighLeft, ')
          ..write('thighRight: $thighRight, ')
          ..write('calfLeft: $calfLeft, ')
          ..write('calfRight: $calfRight, ')
          ..write('date: $date')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      bodyFatPercentage,
      muscleMassPercentage,
      neckCircumference,
      chestCircumference,
      waistCircumference,
      hipCircumference,
      bicepLeft,
      bicepRight,
      thighLeft,
      thighRight,
      calfLeft,
      calfRight,
      date);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AdvancedBodyMeasurement &&
          other.id == this.id &&
          other.bodyFatPercentage == this.bodyFatPercentage &&
          other.muscleMassPercentage == this.muscleMassPercentage &&
          other.neckCircumference == this.neckCircumference &&
          other.chestCircumference == this.chestCircumference &&
          other.waistCircumference == this.waistCircumference &&
          other.hipCircumference == this.hipCircumference &&
          other.bicepLeft == this.bicepLeft &&
          other.bicepRight == this.bicepRight &&
          other.thighLeft == this.thighLeft &&
          other.thighRight == this.thighRight &&
          other.calfLeft == this.calfLeft &&
          other.calfRight == this.calfRight &&
          other.date == this.date);
}

class AdvancedBodyMeasurementsCompanion
    extends UpdateCompanion<AdvancedBodyMeasurement> {
  final Value<int> id;
  final Value<int?> bodyFatPercentage;
  final Value<int?> muscleMassPercentage;
  final Value<double?> neckCircumference;
  final Value<double?> chestCircumference;
  final Value<double?> waistCircumference;
  final Value<double?> hipCircumference;
  final Value<double?> bicepLeft;
  final Value<double?> bicepRight;
  final Value<double?> thighLeft;
  final Value<double?> thighRight;
  final Value<double?> calfLeft;
  final Value<double?> calfRight;
  final Value<DateTime> date;
  const AdvancedBodyMeasurementsCompanion({
    this.id = const Value.absent(),
    this.bodyFatPercentage = const Value.absent(),
    this.muscleMassPercentage = const Value.absent(),
    this.neckCircumference = const Value.absent(),
    this.chestCircumference = const Value.absent(),
    this.waistCircumference = const Value.absent(),
    this.hipCircumference = const Value.absent(),
    this.bicepLeft = const Value.absent(),
    this.bicepRight = const Value.absent(),
    this.thighLeft = const Value.absent(),
    this.thighRight = const Value.absent(),
    this.calfLeft = const Value.absent(),
    this.calfRight = const Value.absent(),
    this.date = const Value.absent(),
  });
  AdvancedBodyMeasurementsCompanion.insert({
    this.id = const Value.absent(),
    this.bodyFatPercentage = const Value.absent(),
    this.muscleMassPercentage = const Value.absent(),
    this.neckCircumference = const Value.absent(),
    this.chestCircumference = const Value.absent(),
    this.waistCircumference = const Value.absent(),
    this.hipCircumference = const Value.absent(),
    this.bicepLeft = const Value.absent(),
    this.bicepRight = const Value.absent(),
    this.thighLeft = const Value.absent(),
    this.thighRight = const Value.absent(),
    this.calfLeft = const Value.absent(),
    this.calfRight = const Value.absent(),
    required DateTime date,
  }) : date = Value(date);
  static Insertable<AdvancedBodyMeasurement> custom({
    Expression<int>? id,
    Expression<int>? bodyFatPercentage,
    Expression<int>? muscleMassPercentage,
    Expression<double>? neckCircumference,
    Expression<double>? chestCircumference,
    Expression<double>? waistCircumference,
    Expression<double>? hipCircumference,
    Expression<double>? bicepLeft,
    Expression<double>? bicepRight,
    Expression<double>? thighLeft,
    Expression<double>? thighRight,
    Expression<double>? calfLeft,
    Expression<double>? calfRight,
    Expression<String>? date,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bodyFatPercentage != null) 'bodyFatPercentage': bodyFatPercentage,
      if (muscleMassPercentage != null)
        'muscleMassPercentage': muscleMassPercentage,
      if (neckCircumference != null) 'neckCircumference': neckCircumference,
      if (chestCircumference != null) 'chestCircumference': chestCircumference,
      if (waistCircumference != null) 'waistCircumference': waistCircumference,
      if (hipCircumference != null) 'hipCircumference': hipCircumference,
      if (bicepLeft != null) 'bicepLeft': bicepLeft,
      if (bicepRight != null) 'bicepRight': bicepRight,
      if (thighLeft != null) 'thighLeft': thighLeft,
      if (thighRight != null) 'thighRight': thighRight,
      if (calfLeft != null) 'calfLeft': calfLeft,
      if (calfRight != null) 'calfRight': calfRight,
      if (date != null) 'date': date,
    });
  }

  AdvancedBodyMeasurementsCompanion copyWith(
      {Value<int>? id,
      Value<int?>? bodyFatPercentage,
      Value<int?>? muscleMassPercentage,
      Value<double?>? neckCircumference,
      Value<double?>? chestCircumference,
      Value<double?>? waistCircumference,
      Value<double?>? hipCircumference,
      Value<double?>? bicepLeft,
      Value<double?>? bicepRight,
      Value<double?>? thighLeft,
      Value<double?>? thighRight,
      Value<double?>? calfLeft,
      Value<double?>? calfRight,
      Value<DateTime>? date}) {
    return AdvancedBodyMeasurementsCompanion(
      id: id ?? this.id,
      bodyFatPercentage: bodyFatPercentage ?? this.bodyFatPercentage,
      muscleMassPercentage: muscleMassPercentage ?? this.muscleMassPercentage,
      neckCircumference: neckCircumference ?? this.neckCircumference,
      chestCircumference: chestCircumference ?? this.chestCircumference,
      waistCircumference: waistCircumference ?? this.waistCircumference,
      hipCircumference: hipCircumference ?? this.hipCircumference,
      bicepLeft: bicepLeft ?? this.bicepLeft,
      bicepRight: bicepRight ?? this.bicepRight,
      thighLeft: thighLeft ?? this.thighLeft,
      thighRight: thighRight ?? this.thighRight,
      calfLeft: calfLeft ?? this.calfLeft,
      calfRight: calfRight ?? this.calfRight,
      date: date ?? this.date,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (bodyFatPercentage.present) {
      map['bodyFatPercentage'] = Variable<int>(bodyFatPercentage.value);
    }
    if (muscleMassPercentage.present) {
      map['muscleMassPercentage'] = Variable<int>(muscleMassPercentage.value);
    }
    if (neckCircumference.present) {
      map['neckCircumference'] = Variable<double>(neckCircumference.value);
    }
    if (chestCircumference.present) {
      map['chestCircumference'] = Variable<double>(chestCircumference.value);
    }
    if (waistCircumference.present) {
      map['waistCircumference'] = Variable<double>(waistCircumference.value);
    }
    if (hipCircumference.present) {
      map['hipCircumference'] = Variable<double>(hipCircumference.value);
    }
    if (bicepLeft.present) {
      map['bicepLeft'] = Variable<double>(bicepLeft.value);
    }
    if (bicepRight.present) {
      map['bicepRight'] = Variable<double>(bicepRight.value);
    }
    if (thighLeft.present) {
      map['thighLeft'] = Variable<double>(thighLeft.value);
    }
    if (thighRight.present) {
      map['thighRight'] = Variable<double>(thighRight.value);
    }
    if (calfLeft.present) {
      map['calfLeft'] = Variable<double>(calfLeft.value);
    }
    if (calfRight.present) {
      map['calfRight'] = Variable<double>(calfRight.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(
          $AdvancedBodyMeasurementsTable.$converterdate.toSql(date.value));
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AdvancedBodyMeasurementsCompanion(')
          ..write('id: $id, ')
          ..write('bodyFatPercentage: $bodyFatPercentage, ')
          ..write('muscleMassPercentage: $muscleMassPercentage, ')
          ..write('neckCircumference: $neckCircumference, ')
          ..write('chestCircumference: $chestCircumference, ')
          ..write('waistCircumference: $waistCircumference, ')
          ..write('hipCircumference: $hipCircumference, ')
          ..write('bicepLeft: $bicepLeft, ')
          ..write('bicepRight: $bicepRight, ')
          ..write('thighLeft: $thighLeft, ')
          ..write('thighRight: $thighRight, ')
          ..write('calfLeft: $calfLeft, ')
          ..write('calfRight: $calfRight, ')
          ..write('date: $date')
          ..write(')'))
        .toString();
  }
}

class $ActivityMeasurementsTable extends ActivityMeasurements
    with TableInfo<$ActivityMeasurementsTable, ActivityMeasurement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ActivityMeasurementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _wakingRHRMeta =
      const VerificationMeta('wakingRHR');
  @override
  late final GeneratedColumn<int> wakingRHR = GeneratedColumn<int>(
      'wakingRHR', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _wakingHRVMeta =
      const VerificationMeta('wakingHRV');
  @override
  late final GeneratedColumn<int> wakingHRV = GeneratedColumn<int>(
      'wakingHRV', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _dailyStepsMeta =
      const VerificationMeta('dailySteps');
  @override
  late final GeneratedColumn<int> dailySteps = GeneratedColumn<int>(
      'dailySteps', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _activeEnergyBurnedMeta =
      const VerificationMeta('activeEnergyBurned');
  @override
  late final GeneratedColumn<double> activeEnergyBurned =
      GeneratedColumn<double>('activeEnergyBurned', aliasedName, true,
          type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _vo2MaxMeta = const VerificationMeta('vo2Max');
  @override
  late final GeneratedColumn<double> vo2Max = GeneratedColumn<double>(
      'vo2Max', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> date =
      GeneratedColumn<String>('date', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<DateTime>($ActivityMeasurementsTable.$converterdate);
  @override
  List<GeneratedColumn> get $columns =>
      [id, wakingRHR, wakingHRV, dailySteps, activeEnergyBurned, vo2Max, date];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'activity_measurements';
  @override
  VerificationContext validateIntegrity(
      Insertable<ActivityMeasurement> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('wakingRHR')) {
      context.handle(_wakingRHRMeta,
          wakingRHR.isAcceptableOrUnknown(data['wakingRHR']!, _wakingRHRMeta));
    }
    if (data.containsKey('wakingHRV')) {
      context.handle(_wakingHRVMeta,
          wakingHRV.isAcceptableOrUnknown(data['wakingHRV']!, _wakingHRVMeta));
    }
    if (data.containsKey('dailySteps')) {
      context.handle(
          _dailyStepsMeta,
          dailySteps.isAcceptableOrUnknown(
              data['dailySteps']!, _dailyStepsMeta));
    }
    if (data.containsKey('activeEnergyBurned')) {
      context.handle(
          _activeEnergyBurnedMeta,
          activeEnergyBurned.isAcceptableOrUnknown(
              data['activeEnergyBurned']!, _activeEnergyBurnedMeta));
    }
    if (data.containsKey('vo2Max')) {
      context.handle(_vo2MaxMeta,
          vo2Max.isAcceptableOrUnknown(data['vo2Max']!, _vo2MaxMeta));
    }
    context.handle(_dateMeta, const VerificationResult.success());
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ActivityMeasurement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ActivityMeasurement(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      wakingRHR: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}wakingRHR']),
      wakingHRV: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}wakingHRV']),
      dailySteps: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}dailySteps']),
      activeEnergyBurned: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}activeEnergyBurned']),
      vo2Max: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}vo2Max']),
      date: $ActivityMeasurementsTable.$converterdate.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}date'])!),
    );
  }

  @override
  $ActivityMeasurementsTable createAlias(String alias) {
    return $ActivityMeasurementsTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, String> $converterdate =
      const IsoDateTimeConverter();
}

class ActivityMeasurement extends DataClass
    implements Insertable<ActivityMeasurement> {
  final int id;
  final int? wakingRHR;
  final int? wakingHRV;
  final int? dailySteps;
  final double? activeEnergyBurned;
  final double? vo2Max;
  final DateTime date;
  const ActivityMeasurement(
      {required this.id,
      this.wakingRHR,
      this.wakingHRV,
      this.dailySteps,
      this.activeEnergyBurned,
      this.vo2Max,
      required this.date});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || wakingRHR != null) {
      map['wakingRHR'] = Variable<int>(wakingRHR);
    }
    if (!nullToAbsent || wakingHRV != null) {
      map['wakingHRV'] = Variable<int>(wakingHRV);
    }
    if (!nullToAbsent || dailySteps != null) {
      map['dailySteps'] = Variable<int>(dailySteps);
    }
    if (!nullToAbsent || activeEnergyBurned != null) {
      map['activeEnergyBurned'] = Variable<double>(activeEnergyBurned);
    }
    if (!nullToAbsent || vo2Max != null) {
      map['vo2Max'] = Variable<double>(vo2Max);
    }
    {
      map['date'] = Variable<String>(
          $ActivityMeasurementsTable.$converterdate.toSql(date));
    }
    return map;
  }

  ActivityMeasurementsCompanion toCompanion(bool nullToAbsent) {
    return ActivityMeasurementsCompanion(
      id: Value(id),
      wakingRHR: wakingRHR == null && nullToAbsent
          ? const Value.absent()
          : Value(wakingRHR),
      wakingHRV: wakingHRV == null && nullToAbsent
          ? const Value.absent()
          : Value(wakingHRV),
      dailySteps: dailySteps == null && nullToAbsent
          ? const Value.absent()
          : Value(dailySteps),
      activeEnergyBurned: activeEnergyBurned == null && nullToAbsent
          ? const Value.absent()
          : Value(activeEnergyBurned),
      vo2Max:
          vo2Max == null && nullToAbsent ? const Value.absent() : Value(vo2Max),
      date: Value(date),
    );
  }

  factory ActivityMeasurement.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ActivityMeasurement(
      id: serializer.fromJson<int>(json['id']),
      wakingRHR: serializer.fromJson<int?>(json['wakingRHR']),
      wakingHRV: serializer.fromJson<int?>(json['wakingHRV']),
      dailySteps: serializer.fromJson<int?>(json['dailySteps']),
      activeEnergyBurned:
          serializer.fromJson<double?>(json['activeEnergyBurned']),
      vo2Max: serializer.fromJson<double?>(json['vo2Max']),
      date: serializer.fromJson<DateTime>(json['date']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'wakingRHR': serializer.toJson<int?>(wakingRHR),
      'wakingHRV': serializer.toJson<int?>(wakingHRV),
      'dailySteps': serializer.toJson<int?>(dailySteps),
      'activeEnergyBurned': serializer.toJson<double?>(activeEnergyBurned),
      'vo2Max': serializer.toJson<double?>(vo2Max),
      'date': serializer.toJson<DateTime>(date),
    };
  }

  ActivityMeasurement copyWith(
          {int? id,
          Value<int?> wakingRHR = const Value.absent(),
          Value<int?> wakingHRV = const Value.absent(),
          Value<int?> dailySteps = const Value.absent(),
          Value<double?> activeEnergyBurned = const Value.absent(),
          Value<double?> vo2Max = const Value.absent(),
          DateTime? date}) =>
      ActivityMeasurement(
        id: id ?? this.id,
        wakingRHR: wakingRHR.present ? wakingRHR.value : this.wakingRHR,
        wakingHRV: wakingHRV.present ? wakingHRV.value : this.wakingHRV,
        dailySteps: dailySteps.present ? dailySteps.value : this.dailySteps,
        activeEnergyBurned: activeEnergyBurned.present
            ? activeEnergyBurned.value
            : this.activeEnergyBurned,
        vo2Max: vo2Max.present ? vo2Max.value : this.vo2Max,
        date: date ?? this.date,
      );
  @override
  String toString() {
    return (StringBuffer('ActivityMeasurement(')
          ..write('id: $id, ')
          ..write('wakingRHR: $wakingRHR, ')
          ..write('wakingHRV: $wakingHRV, ')
          ..write('dailySteps: $dailySteps, ')
          ..write('activeEnergyBurned: $activeEnergyBurned, ')
          ..write('vo2Max: $vo2Max, ')
          ..write('date: $date')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, wakingRHR, wakingHRV, dailySteps, activeEnergyBurned, vo2Max, date);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ActivityMeasurement &&
          other.id == this.id &&
          other.wakingRHR == this.wakingRHR &&
          other.wakingHRV == this.wakingHRV &&
          other.dailySteps == this.dailySteps &&
          other.activeEnergyBurned == this.activeEnergyBurned &&
          other.vo2Max == this.vo2Max &&
          other.date == this.date);
}

class ActivityMeasurementsCompanion
    extends UpdateCompanion<ActivityMeasurement> {
  final Value<int> id;
  final Value<int?> wakingRHR;
  final Value<int?> wakingHRV;
  final Value<int?> dailySteps;
  final Value<double?> activeEnergyBurned;
  final Value<double?> vo2Max;
  final Value<DateTime> date;
  const ActivityMeasurementsCompanion({
    this.id = const Value.absent(),
    this.wakingRHR = const Value.absent(),
    this.wakingHRV = const Value.absent(),
    this.dailySteps = const Value.absent(),
    this.activeEnergyBurned = const Value.absent(),
    this.vo2Max = const Value.absent(),
    this.date = const Value.absent(),
  });
  ActivityMeasurementsCompanion.insert({
    this.id = const Value.absent(),
    this.wakingRHR = const Value.absent(),
    this.wakingHRV = const Value.absent(),
    this.dailySteps = const Value.absent(),
    this.activeEnergyBurned = const Value.absent(),
    this.vo2Max = const Value.absent(),
    required DateTime date,
  }) : date = Value(date);
  static Insertable<ActivityMeasurement> custom({
    Expression<int>? id,
    Expression<int>? wakingRHR,
    Expression<int>? wakingHRV,
    Expression<int>? dailySteps,
    Expression<double>? activeEnergyBurned,
    Expression<double>? vo2Max,
    Expression<String>? date,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (wakingRHR != null) 'wakingRHR': wakingRHR,
      if (wakingHRV != null) 'wakingHRV': wakingHRV,
      if (dailySteps != null) 'dailySteps': dailySteps,
      if (activeEnergyBurned != null) 'activeEnergyBurned': activeEnergyBurned,
      if (vo2Max != null) 'vo2Max': vo2Max,
      if (date != null) 'date': date,
    });
  }

  ActivityMeasurementsCompanion copyWith(
      {Value<int>? id,
      Value<int?>? wakingRHR,
      Value<int?>? wakingHRV,
      Value<int?>? dailySteps,
      Value<double?>? activeEnergyBurned,
      Value<double?>? vo2Max,
      Value<DateTime>? date}) {
    return ActivityMeasurementsCompanion(
      id: id ?? this.id,
      wakingRHR: wakingRHR ?? this.wakingRHR,
      wakingHRV: wakingHRV ?? this.wakingHRV,
      dailySteps: dailySteps ?? this.dailySteps,
      activeEnergyBurned: activeEnergyBurned ?? this.activeEnergyBurned,
      vo2Max: vo2Max ?? this.vo2Max,
      date: date ?? this.date,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (wakingRHR.present) {
      map['wakingRHR'] = Variable<int>(wakingRHR.value);
    }
    if (wakingHRV.present) {
      map['wakingHRV'] = Variable<int>(wakingHRV.value);
    }
    if (dailySteps.present) {
      map['dailySteps'] = Variable<int>(dailySteps.value);
    }
    if (activeEnergyBurned.present) {
      map['activeEnergyBurned'] = Variable<double>(activeEnergyBurned.value);
    }
    if (vo2Max.present) {
      map['vo2Max'] = Variable<double>(vo2Max.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(
          $ActivityMeasurementsTable.$converterdate.toSql(date.value));
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ActivityMeasurementsCompanion(')
          ..write('id: $id, ')
          ..write('wakingRHR: $wakingRHR, ')
          ..write('wakingHRV: $wakingHRV, ')
          ..write('dailySteps: $dailySteps, ')
          ..write('activeEnergyBurned: $activeEnergyBurned, ')
          ..write('vo2Max: $vo2Max, ')
          ..write('date: $date')
          ..write(')'))
        .toString();
  }
}

class $SleepMeasurementsTable extends SleepMeasurements
    with TableInfo<$SleepMeasurementsTable, SleepMeasurement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SleepMeasurementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _sleepDurationMeta =
      const VerificationMeta('sleepDuration');
  @override
  late final GeneratedColumn<double> sleepDuration = GeneratedColumn<double>(
      'sleepDuration', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _deepSleepDurationMeta =
      const VerificationMeta('deepSleepDuration');
  @override
  late final GeneratedColumn<double> deepSleepDuration =
      GeneratedColumn<double>('deepSleepDuration', aliasedName, true,
          type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _lightSleepDurationMeta =
      const VerificationMeta('lightSleepDuration');
  @override
  late final GeneratedColumn<double> lightSleepDuration =
      GeneratedColumn<double>('lightSleepDuration', aliasedName, true,
          type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _remSleepDurationMeta =
      const VerificationMeta('remSleepDuration');
  @override
  late final GeneratedColumn<double> remSleepDuration = GeneratedColumn<double>(
      'remSleepDuration', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _sleepingRHRMeta =
      const VerificationMeta('sleepingRHR');
  @override
  late final GeneratedColumn<int> sleepingRHR = GeneratedColumn<int>(
      'sleepingRHR', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _sleepingHRVMeta =
      const VerificationMeta('sleepingHRV');
  @override
  late final GeneratedColumn<int> sleepingHRV = GeneratedColumn<int>(
      'sleepingHRV', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> date =
      GeneratedColumn<String>('date', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<DateTime>($SleepMeasurementsTable.$converterdate);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        sleepDuration,
        deepSleepDuration,
        lightSleepDuration,
        remSleepDuration,
        sleepingRHR,
        sleepingHRV,
        date
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sleep_measurements';
  @override
  VerificationContext validateIntegrity(Insertable<SleepMeasurement> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('sleepDuration')) {
      context.handle(
          _sleepDurationMeta,
          sleepDuration.isAcceptableOrUnknown(
              data['sleepDuration']!, _sleepDurationMeta));
    }
    if (data.containsKey('deepSleepDuration')) {
      context.handle(
          _deepSleepDurationMeta,
          deepSleepDuration.isAcceptableOrUnknown(
              data['deepSleepDuration']!, _deepSleepDurationMeta));
    }
    if (data.containsKey('lightSleepDuration')) {
      context.handle(
          _lightSleepDurationMeta,
          lightSleepDuration.isAcceptableOrUnknown(
              data['lightSleepDuration']!, _lightSleepDurationMeta));
    }
    if (data.containsKey('remSleepDuration')) {
      context.handle(
          _remSleepDurationMeta,
          remSleepDuration.isAcceptableOrUnknown(
              data['remSleepDuration']!, _remSleepDurationMeta));
    }
    if (data.containsKey('sleepingRHR')) {
      context.handle(
          _sleepingRHRMeta,
          sleepingRHR.isAcceptableOrUnknown(
              data['sleepingRHR']!, _sleepingRHRMeta));
    }
    if (data.containsKey('sleepingHRV')) {
      context.handle(
          _sleepingHRVMeta,
          sleepingHRV.isAcceptableOrUnknown(
              data['sleepingHRV']!, _sleepingHRVMeta));
    }
    context.handle(_dateMeta, const VerificationResult.success());
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SleepMeasurement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SleepMeasurement(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      sleepDuration: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}sleepDuration']),
      deepSleepDuration: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}deepSleepDuration']),
      lightSleepDuration: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}lightSleepDuration']),
      remSleepDuration: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}remSleepDuration']),
      sleepingRHR: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sleepingRHR']),
      sleepingHRV: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sleepingHRV']),
      date: $SleepMeasurementsTable.$converterdate.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}date'])!),
    );
  }

  @override
  $SleepMeasurementsTable createAlias(String alias) {
    return $SleepMeasurementsTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, String> $converterdate =
      const IsoDateTimeConverter();
}

class SleepMeasurement extends DataClass
    implements Insertable<SleepMeasurement> {
  final int id;
  final double? sleepDuration;
  final double? deepSleepDuration;
  final double? lightSleepDuration;
  final double? remSleepDuration;
  final int? sleepingRHR;
  final int? sleepingHRV;
  final DateTime date;
  const SleepMeasurement(
      {required this.id,
      this.sleepDuration,
      this.deepSleepDuration,
      this.lightSleepDuration,
      this.remSleepDuration,
      this.sleepingRHR,
      this.sleepingHRV,
      required this.date});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || sleepDuration != null) {
      map['sleepDuration'] = Variable<double>(sleepDuration);
    }
    if (!nullToAbsent || deepSleepDuration != null) {
      map['deepSleepDuration'] = Variable<double>(deepSleepDuration);
    }
    if (!nullToAbsent || lightSleepDuration != null) {
      map['lightSleepDuration'] = Variable<double>(lightSleepDuration);
    }
    if (!nullToAbsent || remSleepDuration != null) {
      map['remSleepDuration'] = Variable<double>(remSleepDuration);
    }
    if (!nullToAbsent || sleepingRHR != null) {
      map['sleepingRHR'] = Variable<int>(sleepingRHR);
    }
    if (!nullToAbsent || sleepingHRV != null) {
      map['sleepingHRV'] = Variable<int>(sleepingHRV);
    }
    {
      map['date'] =
          Variable<String>($SleepMeasurementsTable.$converterdate.toSql(date));
    }
    return map;
  }

  SleepMeasurementsCompanion toCompanion(bool nullToAbsent) {
    return SleepMeasurementsCompanion(
      id: Value(id),
      sleepDuration: sleepDuration == null && nullToAbsent
          ? const Value.absent()
          : Value(sleepDuration),
      deepSleepDuration: deepSleepDuration == null && nullToAbsent
          ? const Value.absent()
          : Value(deepSleepDuration),
      lightSleepDuration: lightSleepDuration == null && nullToAbsent
          ? const Value.absent()
          : Value(lightSleepDuration),
      remSleepDuration: remSleepDuration == null && nullToAbsent
          ? const Value.absent()
          : Value(remSleepDuration),
      sleepingRHR: sleepingRHR == null && nullToAbsent
          ? const Value.absent()
          : Value(sleepingRHR),
      sleepingHRV: sleepingHRV == null && nullToAbsent
          ? const Value.absent()
          : Value(sleepingHRV),
      date: Value(date),
    );
  }

  factory SleepMeasurement.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SleepMeasurement(
      id: serializer.fromJson<int>(json['id']),
      sleepDuration: serializer.fromJson<double?>(json['sleepDuration']),
      deepSleepDuration:
          serializer.fromJson<double?>(json['deepSleepDuration']),
      lightSleepDuration:
          serializer.fromJson<double?>(json['lightSleepDuration']),
      remSleepDuration: serializer.fromJson<double?>(json['remSleepDuration']),
      sleepingRHR: serializer.fromJson<int?>(json['sleepingRHR']),
      sleepingHRV: serializer.fromJson<int?>(json['sleepingHRV']),
      date: serializer.fromJson<DateTime>(json['date']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sleepDuration': serializer.toJson<double?>(sleepDuration),
      'deepSleepDuration': serializer.toJson<double?>(deepSleepDuration),
      'lightSleepDuration': serializer.toJson<double?>(lightSleepDuration),
      'remSleepDuration': serializer.toJson<double?>(remSleepDuration),
      'sleepingRHR': serializer.toJson<int?>(sleepingRHR),
      'sleepingHRV': serializer.toJson<int?>(sleepingHRV),
      'date': serializer.toJson<DateTime>(date),
    };
  }

  SleepMeasurement copyWith(
          {int? id,
          Value<double?> sleepDuration = const Value.absent(),
          Value<double?> deepSleepDuration = const Value.absent(),
          Value<double?> lightSleepDuration = const Value.absent(),
          Value<double?> remSleepDuration = const Value.absent(),
          Value<int?> sleepingRHR = const Value.absent(),
          Value<int?> sleepingHRV = const Value.absent(),
          DateTime? date}) =>
      SleepMeasurement(
        id: id ?? this.id,
        sleepDuration:
            sleepDuration.present ? sleepDuration.value : this.sleepDuration,
        deepSleepDuration: deepSleepDuration.present
            ? deepSleepDuration.value
            : this.deepSleepDuration,
        lightSleepDuration: lightSleepDuration.present
            ? lightSleepDuration.value
            : this.lightSleepDuration,
        remSleepDuration: remSleepDuration.present
            ? remSleepDuration.value
            : this.remSleepDuration,
        sleepingRHR: sleepingRHR.present ? sleepingRHR.value : this.sleepingRHR,
        sleepingHRV: sleepingHRV.present ? sleepingHRV.value : this.sleepingHRV,
        date: date ?? this.date,
      );
  @override
  String toString() {
    return (StringBuffer('SleepMeasurement(')
          ..write('id: $id, ')
          ..write('sleepDuration: $sleepDuration, ')
          ..write('deepSleepDuration: $deepSleepDuration, ')
          ..write('lightSleepDuration: $lightSleepDuration, ')
          ..write('remSleepDuration: $remSleepDuration, ')
          ..write('sleepingRHR: $sleepingRHR, ')
          ..write('sleepingHRV: $sleepingHRV, ')
          ..write('date: $date')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, sleepDuration, deepSleepDuration,
      lightSleepDuration, remSleepDuration, sleepingRHR, sleepingHRV, date);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SleepMeasurement &&
          other.id == this.id &&
          other.sleepDuration == this.sleepDuration &&
          other.deepSleepDuration == this.deepSleepDuration &&
          other.lightSleepDuration == this.lightSleepDuration &&
          other.remSleepDuration == this.remSleepDuration &&
          other.sleepingRHR == this.sleepingRHR &&
          other.sleepingHRV == this.sleepingHRV &&
          other.date == this.date);
}

class SleepMeasurementsCompanion extends UpdateCompanion<SleepMeasurement> {
  final Value<int> id;
  final Value<double?> sleepDuration;
  final Value<double?> deepSleepDuration;
  final Value<double?> lightSleepDuration;
  final Value<double?> remSleepDuration;
  final Value<int?> sleepingRHR;
  final Value<int?> sleepingHRV;
  final Value<DateTime> date;
  const SleepMeasurementsCompanion({
    this.id = const Value.absent(),
    this.sleepDuration = const Value.absent(),
    this.deepSleepDuration = const Value.absent(),
    this.lightSleepDuration = const Value.absent(),
    this.remSleepDuration = const Value.absent(),
    this.sleepingRHR = const Value.absent(),
    this.sleepingHRV = const Value.absent(),
    this.date = const Value.absent(),
  });
  SleepMeasurementsCompanion.insert({
    this.id = const Value.absent(),
    this.sleepDuration = const Value.absent(),
    this.deepSleepDuration = const Value.absent(),
    this.lightSleepDuration = const Value.absent(),
    this.remSleepDuration = const Value.absent(),
    this.sleepingRHR = const Value.absent(),
    this.sleepingHRV = const Value.absent(),
    required DateTime date,
  }) : date = Value(date);
  static Insertable<SleepMeasurement> custom({
    Expression<int>? id,
    Expression<double>? sleepDuration,
    Expression<double>? deepSleepDuration,
    Expression<double>? lightSleepDuration,
    Expression<double>? remSleepDuration,
    Expression<int>? sleepingRHR,
    Expression<int>? sleepingHRV,
    Expression<String>? date,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sleepDuration != null) 'sleepDuration': sleepDuration,
      if (deepSleepDuration != null) 'deepSleepDuration': deepSleepDuration,
      if (lightSleepDuration != null) 'lightSleepDuration': lightSleepDuration,
      if (remSleepDuration != null) 'remSleepDuration': remSleepDuration,
      if (sleepingRHR != null) 'sleepingRHR': sleepingRHR,
      if (sleepingHRV != null) 'sleepingHRV': sleepingHRV,
      if (date != null) 'date': date,
    });
  }

  SleepMeasurementsCompanion copyWith(
      {Value<int>? id,
      Value<double?>? sleepDuration,
      Value<double?>? deepSleepDuration,
      Value<double?>? lightSleepDuration,
      Value<double?>? remSleepDuration,
      Value<int?>? sleepingRHR,
      Value<int?>? sleepingHRV,
      Value<DateTime>? date}) {
    return SleepMeasurementsCompanion(
      id: id ?? this.id,
      sleepDuration: sleepDuration ?? this.sleepDuration,
      deepSleepDuration: deepSleepDuration ?? this.deepSleepDuration,
      lightSleepDuration: lightSleepDuration ?? this.lightSleepDuration,
      remSleepDuration: remSleepDuration ?? this.remSleepDuration,
      sleepingRHR: sleepingRHR ?? this.sleepingRHR,
      sleepingHRV: sleepingHRV ?? this.sleepingHRV,
      date: date ?? this.date,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sleepDuration.present) {
      map['sleepDuration'] = Variable<double>(sleepDuration.value);
    }
    if (deepSleepDuration.present) {
      map['deepSleepDuration'] = Variable<double>(deepSleepDuration.value);
    }
    if (lightSleepDuration.present) {
      map['lightSleepDuration'] = Variable<double>(lightSleepDuration.value);
    }
    if (remSleepDuration.present) {
      map['remSleepDuration'] = Variable<double>(remSleepDuration.value);
    }
    if (sleepingRHR.present) {
      map['sleepingRHR'] = Variable<int>(sleepingRHR.value);
    }
    if (sleepingHRV.present) {
      map['sleepingHRV'] = Variable<int>(sleepingHRV.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(
          $SleepMeasurementsTable.$converterdate.toSql(date.value));
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SleepMeasurementsCompanion(')
          ..write('id: $id, ')
          ..write('sleepDuration: $sleepDuration, ')
          ..write('deepSleepDuration: $deepSleepDuration, ')
          ..write('lightSleepDuration: $lightSleepDuration, ')
          ..write('remSleepDuration: $remSleepDuration, ')
          ..write('sleepingRHR: $sleepingRHR, ')
          ..write('sleepingHRV: $sleepingHRV, ')
          ..write('date: $date')
          ..write(')'))
        .toString();
  }
}

class $AdvancedSleepMeasurementsTable extends AdvancedSleepMeasurements
    with TableInfo<$AdvancedSleepMeasurementsTable, AdvancedSleepMeasurement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AdvancedSleepMeasurementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _timeInBedMeta =
      const VerificationMeta('timeInBed');
  @override
  late final GeneratedColumn<double> timeInBed = GeneratedColumn<double>(
      'timeInBed', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _totalAwakeTimeMeta =
      const VerificationMeta('totalAwakeTime');
  @override
  late final GeneratedColumn<double> totalAwakeTime = GeneratedColumn<double>(
      'totalAwakeTime', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _numberOfAwakeningsMeta =
      const VerificationMeta('numberOfAwakenings');
  @override
  late final GeneratedColumn<int> numberOfAwakenings = GeneratedColumn<int>(
      'numberOfAwakenings', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _longestAwakePeriodMeta =
      const VerificationMeta('longestAwakePeriod');
  @override
  late final GeneratedColumn<double> longestAwakePeriod =
      GeneratedColumn<double>('longestAwakePeriod', aliasedName, true,
          type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _sleepLatencyMeta =
      const VerificationMeta('sleepLatency');
  @override
  late final GeneratedColumn<double> sleepLatency = GeneratedColumn<double>(
      'sleepLatency', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _deepSleepLatencyMeta =
      const VerificationMeta('deepSleepLatency');
  @override
  late final GeneratedColumn<double> deepSleepLatency = GeneratedColumn<double>(
      'deepSleepLatency', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _remSleepLatencyMeta =
      const VerificationMeta('remSleepLatency');
  @override
  late final GeneratedColumn<double> remSleepLatency = GeneratedColumn<double>(
      'remSleepLatency', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _deepSleepFragmentationMeta =
      const VerificationMeta('deepSleepFragmentation');
  @override
  late final GeneratedColumn<double> deepSleepFragmentation =
      GeneratedColumn<double>('deepSleepFragmentation', aliasedName, true,
          type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _lightSleepFragmentationMeta =
      const VerificationMeta('lightSleepFragmentation');
  @override
  late final GeneratedColumn<double> lightSleepFragmentation =
      GeneratedColumn<double>('lightSleepFragmentation', aliasedName, true,
          type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _remSleepFragmentationMeta =
      const VerificationMeta('remSleepFragmentation');
  @override
  late final GeneratedColumn<double> remSleepFragmentation =
      GeneratedColumn<double>('remSleepFragmentation', aliasedName, true,
          type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> date =
      GeneratedColumn<String>('date', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<DateTime>(
              $AdvancedSleepMeasurementsTable.$converterdate);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        timeInBed,
        totalAwakeTime,
        numberOfAwakenings,
        longestAwakePeriod,
        sleepLatency,
        deepSleepLatency,
        remSleepLatency,
        deepSleepFragmentation,
        lightSleepFragmentation,
        remSleepFragmentation,
        date,
        notes
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'advanced_sleep_measurements';
  @override
  VerificationContext validateIntegrity(
      Insertable<AdvancedSleepMeasurement> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('timeInBed')) {
      context.handle(_timeInBedMeta,
          timeInBed.isAcceptableOrUnknown(data['timeInBed']!, _timeInBedMeta));
    }
    if (data.containsKey('totalAwakeTime')) {
      context.handle(
          _totalAwakeTimeMeta,
          totalAwakeTime.isAcceptableOrUnknown(
              data['totalAwakeTime']!, _totalAwakeTimeMeta));
    }
    if (data.containsKey('numberOfAwakenings')) {
      context.handle(
          _numberOfAwakeningsMeta,
          numberOfAwakenings.isAcceptableOrUnknown(
              data['numberOfAwakenings']!, _numberOfAwakeningsMeta));
    }
    if (data.containsKey('longestAwakePeriod')) {
      context.handle(
          _longestAwakePeriodMeta,
          longestAwakePeriod.isAcceptableOrUnknown(
              data['longestAwakePeriod']!, _longestAwakePeriodMeta));
    }
    if (data.containsKey('sleepLatency')) {
      context.handle(
          _sleepLatencyMeta,
          sleepLatency.isAcceptableOrUnknown(
              data['sleepLatency']!, _sleepLatencyMeta));
    }
    if (data.containsKey('deepSleepLatency')) {
      context.handle(
          _deepSleepLatencyMeta,
          deepSleepLatency.isAcceptableOrUnknown(
              data['deepSleepLatency']!, _deepSleepLatencyMeta));
    }
    if (data.containsKey('remSleepLatency')) {
      context.handle(
          _remSleepLatencyMeta,
          remSleepLatency.isAcceptableOrUnknown(
              data['remSleepLatency']!, _remSleepLatencyMeta));
    }
    if (data.containsKey('deepSleepFragmentation')) {
      context.handle(
          _deepSleepFragmentationMeta,
          deepSleepFragmentation.isAcceptableOrUnknown(
              data['deepSleepFragmentation']!, _deepSleepFragmentationMeta));
    }
    if (data.containsKey('lightSleepFragmentation')) {
      context.handle(
          _lightSleepFragmentationMeta,
          lightSleepFragmentation.isAcceptableOrUnknown(
              data['lightSleepFragmentation']!, _lightSleepFragmentationMeta));
    }
    if (data.containsKey('remSleepFragmentation')) {
      context.handle(
          _remSleepFragmentationMeta,
          remSleepFragmentation.isAcceptableOrUnknown(
              data['remSleepFragmentation']!, _remSleepFragmentationMeta));
    }
    context.handle(_dateMeta, const VerificationResult.success());
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AdvancedSleepMeasurement map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AdvancedSleepMeasurement(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      timeInBed: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}timeInBed']),
      totalAwakeTime: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}totalAwakeTime']),
      numberOfAwakenings: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}numberOfAwakenings']),
      longestAwakePeriod: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}longestAwakePeriod']),
      sleepLatency: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}sleepLatency']),
      deepSleepLatency: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}deepSleepLatency']),
      remSleepLatency: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}remSleepLatency']),
      deepSleepFragmentation: attachedDatabase.typeMapping.read(
          DriftSqlType.double,
          data['${effectivePrefix}deepSleepFragmentation']),
      lightSleepFragmentation: attachedDatabase.typeMapping.read(
          DriftSqlType.double,
          data['${effectivePrefix}lightSleepFragmentation']),
      remSleepFragmentation: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}remSleepFragmentation']),
      date: $AdvancedSleepMeasurementsTable.$converterdate.fromSql(
          attachedDatabase.typeMapping
              .read(DriftSqlType.string, data['${effectivePrefix}date'])!),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
    );
  }

  @override
  $AdvancedSleepMeasurementsTable createAlias(String alias) {
    return $AdvancedSleepMeasurementsTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, String> $converterdate =
      const IsoDateTimeConverter();
}

class AdvancedSleepMeasurement extends DataClass
    implements Insertable<AdvancedSleepMeasurement> {
  final int id;
  final double? timeInBed;
  final double? totalAwakeTime;
  final int? numberOfAwakenings;
  final double? longestAwakePeriod;
  final double? sleepLatency;
  final double? deepSleepLatency;
  final double? remSleepLatency;
  final double? deepSleepFragmentation;
  final double? lightSleepFragmentation;
  final double? remSleepFragmentation;
  final DateTime date;
  final String? notes;
  const AdvancedSleepMeasurement(
      {required this.id,
      this.timeInBed,
      this.totalAwakeTime,
      this.numberOfAwakenings,
      this.longestAwakePeriod,
      this.sleepLatency,
      this.deepSleepLatency,
      this.remSleepLatency,
      this.deepSleepFragmentation,
      this.lightSleepFragmentation,
      this.remSleepFragmentation,
      required this.date,
      this.notes});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || timeInBed != null) {
      map['timeInBed'] = Variable<double>(timeInBed);
    }
    if (!nullToAbsent || totalAwakeTime != null) {
      map['totalAwakeTime'] = Variable<double>(totalAwakeTime);
    }
    if (!nullToAbsent || numberOfAwakenings != null) {
      map['numberOfAwakenings'] = Variable<int>(numberOfAwakenings);
    }
    if (!nullToAbsent || longestAwakePeriod != null) {
      map['longestAwakePeriod'] = Variable<double>(longestAwakePeriod);
    }
    if (!nullToAbsent || sleepLatency != null) {
      map['sleepLatency'] = Variable<double>(sleepLatency);
    }
    if (!nullToAbsent || deepSleepLatency != null) {
      map['deepSleepLatency'] = Variable<double>(deepSleepLatency);
    }
    if (!nullToAbsent || remSleepLatency != null) {
      map['remSleepLatency'] = Variable<double>(remSleepLatency);
    }
    if (!nullToAbsent || deepSleepFragmentation != null) {
      map['deepSleepFragmentation'] = Variable<double>(deepSleepFragmentation);
    }
    if (!nullToAbsent || lightSleepFragmentation != null) {
      map['lightSleepFragmentation'] =
          Variable<double>(lightSleepFragmentation);
    }
    if (!nullToAbsent || remSleepFragmentation != null) {
      map['remSleepFragmentation'] = Variable<double>(remSleepFragmentation);
    }
    {
      map['date'] = Variable<String>(
          $AdvancedSleepMeasurementsTable.$converterdate.toSql(date));
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  AdvancedSleepMeasurementsCompanion toCompanion(bool nullToAbsent) {
    return AdvancedSleepMeasurementsCompanion(
      id: Value(id),
      timeInBed: timeInBed == null && nullToAbsent
          ? const Value.absent()
          : Value(timeInBed),
      totalAwakeTime: totalAwakeTime == null && nullToAbsent
          ? const Value.absent()
          : Value(totalAwakeTime),
      numberOfAwakenings: numberOfAwakenings == null && nullToAbsent
          ? const Value.absent()
          : Value(numberOfAwakenings),
      longestAwakePeriod: longestAwakePeriod == null && nullToAbsent
          ? const Value.absent()
          : Value(longestAwakePeriod),
      sleepLatency: sleepLatency == null && nullToAbsent
          ? const Value.absent()
          : Value(sleepLatency),
      deepSleepLatency: deepSleepLatency == null && nullToAbsent
          ? const Value.absent()
          : Value(deepSleepLatency),
      remSleepLatency: remSleepLatency == null && nullToAbsent
          ? const Value.absent()
          : Value(remSleepLatency),
      deepSleepFragmentation: deepSleepFragmentation == null && nullToAbsent
          ? const Value.absent()
          : Value(deepSleepFragmentation),
      lightSleepFragmentation: lightSleepFragmentation == null && nullToAbsent
          ? const Value.absent()
          : Value(lightSleepFragmentation),
      remSleepFragmentation: remSleepFragmentation == null && nullToAbsent
          ? const Value.absent()
          : Value(remSleepFragmentation),
      date: Value(date),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
    );
  }

  factory AdvancedSleepMeasurement.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AdvancedSleepMeasurement(
      id: serializer.fromJson<int>(json['id']),
      timeInBed: serializer.fromJson<double?>(json['timeInBed']),
      totalAwakeTime: serializer.fromJson<double?>(json['totalAwakeTime']),
      numberOfAwakenings: serializer.fromJson<int?>(json['numberOfAwakenings']),
      longestAwakePeriod:
          serializer.fromJson<double?>(json['longestAwakePeriod']),
      sleepLatency: serializer.fromJson<double?>(json['sleepLatency']),
      deepSleepLatency: serializer.fromJson<double?>(json['deepSleepLatency']),
      remSleepLatency: serializer.fromJson<double?>(json['remSleepLatency']),
      deepSleepFragmentation:
          serializer.fromJson<double?>(json['deepSleepFragmentation']),
      lightSleepFragmentation:
          serializer.fromJson<double?>(json['lightSleepFragmentation']),
      remSleepFragmentation:
          serializer.fromJson<double?>(json['remSleepFragmentation']),
      date: serializer.fromJson<DateTime>(json['date']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'timeInBed': serializer.toJson<double?>(timeInBed),
      'totalAwakeTime': serializer.toJson<double?>(totalAwakeTime),
      'numberOfAwakenings': serializer.toJson<int?>(numberOfAwakenings),
      'longestAwakePeriod': serializer.toJson<double?>(longestAwakePeriod),
      'sleepLatency': serializer.toJson<double?>(sleepLatency),
      'deepSleepLatency': serializer.toJson<double?>(deepSleepLatency),
      'remSleepLatency': serializer.toJson<double?>(remSleepLatency),
      'deepSleepFragmentation':
          serializer.toJson<double?>(deepSleepFragmentation),
      'lightSleepFragmentation':
          serializer.toJson<double?>(lightSleepFragmentation),
      'remSleepFragmentation':
          serializer.toJson<double?>(remSleepFragmentation),
      'date': serializer.toJson<DateTime>(date),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  AdvancedSleepMeasurement copyWith(
          {int? id,
          Value<double?> timeInBed = const Value.absent(),
          Value<double?> totalAwakeTime = const Value.absent(),
          Value<int?> numberOfAwakenings = const Value.absent(),
          Value<double?> longestAwakePeriod = const Value.absent(),
          Value<double?> sleepLatency = const Value.absent(),
          Value<double?> deepSleepLatency = const Value.absent(),
          Value<double?> remSleepLatency = const Value.absent(),
          Value<double?> deepSleepFragmentation = const Value.absent(),
          Value<double?> lightSleepFragmentation = const Value.absent(),
          Value<double?> remSleepFragmentation = const Value.absent(),
          DateTime? date,
          Value<String?> notes = const Value.absent()}) =>
      AdvancedSleepMeasurement(
        id: id ?? this.id,
        timeInBed: timeInBed.present ? timeInBed.value : this.timeInBed,
        totalAwakeTime:
            totalAwakeTime.present ? totalAwakeTime.value : this.totalAwakeTime,
        numberOfAwakenings: numberOfAwakenings.present
            ? numberOfAwakenings.value
            : this.numberOfAwakenings,
        longestAwakePeriod: longestAwakePeriod.present
            ? longestAwakePeriod.value
            : this.longestAwakePeriod,
        sleepLatency:
            sleepLatency.present ? sleepLatency.value : this.sleepLatency,
        deepSleepLatency: deepSleepLatency.present
            ? deepSleepLatency.value
            : this.deepSleepLatency,
        remSleepLatency: remSleepLatency.present
            ? remSleepLatency.value
            : this.remSleepLatency,
        deepSleepFragmentation: deepSleepFragmentation.present
            ? deepSleepFragmentation.value
            : this.deepSleepFragmentation,
        lightSleepFragmentation: lightSleepFragmentation.present
            ? lightSleepFragmentation.value
            : this.lightSleepFragmentation,
        remSleepFragmentation: remSleepFragmentation.present
            ? remSleepFragmentation.value
            : this.remSleepFragmentation,
        date: date ?? this.date,
        notes: notes.present ? notes.value : this.notes,
      );
  @override
  String toString() {
    return (StringBuffer('AdvancedSleepMeasurement(')
          ..write('id: $id, ')
          ..write('timeInBed: $timeInBed, ')
          ..write('totalAwakeTime: $totalAwakeTime, ')
          ..write('numberOfAwakenings: $numberOfAwakenings, ')
          ..write('longestAwakePeriod: $longestAwakePeriod, ')
          ..write('sleepLatency: $sleepLatency, ')
          ..write('deepSleepLatency: $deepSleepLatency, ')
          ..write('remSleepLatency: $remSleepLatency, ')
          ..write('deepSleepFragmentation: $deepSleepFragmentation, ')
          ..write('lightSleepFragmentation: $lightSleepFragmentation, ')
          ..write('remSleepFragmentation: $remSleepFragmentation, ')
          ..write('date: $date, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      timeInBed,
      totalAwakeTime,
      numberOfAwakenings,
      longestAwakePeriod,
      sleepLatency,
      deepSleepLatency,
      remSleepLatency,
      deepSleepFragmentation,
      lightSleepFragmentation,
      remSleepFragmentation,
      date,
      notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AdvancedSleepMeasurement &&
          other.id == this.id &&
          other.timeInBed == this.timeInBed &&
          other.totalAwakeTime == this.totalAwakeTime &&
          other.numberOfAwakenings == this.numberOfAwakenings &&
          other.longestAwakePeriod == this.longestAwakePeriod &&
          other.sleepLatency == this.sleepLatency &&
          other.deepSleepLatency == this.deepSleepLatency &&
          other.remSleepLatency == this.remSleepLatency &&
          other.deepSleepFragmentation == this.deepSleepFragmentation &&
          other.lightSleepFragmentation == this.lightSleepFragmentation &&
          other.remSleepFragmentation == this.remSleepFragmentation &&
          other.date == this.date &&
          other.notes == this.notes);
}

class AdvancedSleepMeasurementsCompanion
    extends UpdateCompanion<AdvancedSleepMeasurement> {
  final Value<int> id;
  final Value<double?> timeInBed;
  final Value<double?> totalAwakeTime;
  final Value<int?> numberOfAwakenings;
  final Value<double?> longestAwakePeriod;
  final Value<double?> sleepLatency;
  final Value<double?> deepSleepLatency;
  final Value<double?> remSleepLatency;
  final Value<double?> deepSleepFragmentation;
  final Value<double?> lightSleepFragmentation;
  final Value<double?> remSleepFragmentation;
  final Value<DateTime> date;
  final Value<String?> notes;
  const AdvancedSleepMeasurementsCompanion({
    this.id = const Value.absent(),
    this.timeInBed = const Value.absent(),
    this.totalAwakeTime = const Value.absent(),
    this.numberOfAwakenings = const Value.absent(),
    this.longestAwakePeriod = const Value.absent(),
    this.sleepLatency = const Value.absent(),
    this.deepSleepLatency = const Value.absent(),
    this.remSleepLatency = const Value.absent(),
    this.deepSleepFragmentation = const Value.absent(),
    this.lightSleepFragmentation = const Value.absent(),
    this.remSleepFragmentation = const Value.absent(),
    this.date = const Value.absent(),
    this.notes = const Value.absent(),
  });
  AdvancedSleepMeasurementsCompanion.insert({
    this.id = const Value.absent(),
    this.timeInBed = const Value.absent(),
    this.totalAwakeTime = const Value.absent(),
    this.numberOfAwakenings = const Value.absent(),
    this.longestAwakePeriod = const Value.absent(),
    this.sleepLatency = const Value.absent(),
    this.deepSleepLatency = const Value.absent(),
    this.remSleepLatency = const Value.absent(),
    this.deepSleepFragmentation = const Value.absent(),
    this.lightSleepFragmentation = const Value.absent(),
    this.remSleepFragmentation = const Value.absent(),
    required DateTime date,
    this.notes = const Value.absent(),
  }) : date = Value(date);
  static Insertable<AdvancedSleepMeasurement> custom({
    Expression<int>? id,
    Expression<double>? timeInBed,
    Expression<double>? totalAwakeTime,
    Expression<int>? numberOfAwakenings,
    Expression<double>? longestAwakePeriod,
    Expression<double>? sleepLatency,
    Expression<double>? deepSleepLatency,
    Expression<double>? remSleepLatency,
    Expression<double>? deepSleepFragmentation,
    Expression<double>? lightSleepFragmentation,
    Expression<double>? remSleepFragmentation,
    Expression<String>? date,
    Expression<String>? notes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (timeInBed != null) 'timeInBed': timeInBed,
      if (totalAwakeTime != null) 'totalAwakeTime': totalAwakeTime,
      if (numberOfAwakenings != null) 'numberOfAwakenings': numberOfAwakenings,
      if (longestAwakePeriod != null) 'longestAwakePeriod': longestAwakePeriod,
      if (sleepLatency != null) 'sleepLatency': sleepLatency,
      if (deepSleepLatency != null) 'deepSleepLatency': deepSleepLatency,
      if (remSleepLatency != null) 'remSleepLatency': remSleepLatency,
      if (deepSleepFragmentation != null)
        'deepSleepFragmentation': deepSleepFragmentation,
      if (lightSleepFragmentation != null)
        'lightSleepFragmentation': lightSleepFragmentation,
      if (remSleepFragmentation != null)
        'remSleepFragmentation': remSleepFragmentation,
      if (date != null) 'date': date,
      if (notes != null) 'notes': notes,
    });
  }

  AdvancedSleepMeasurementsCompanion copyWith(
      {Value<int>? id,
      Value<double?>? timeInBed,
      Value<double?>? totalAwakeTime,
      Value<int?>? numberOfAwakenings,
      Value<double?>? longestAwakePeriod,
      Value<double?>? sleepLatency,
      Value<double?>? deepSleepLatency,
      Value<double?>? remSleepLatency,
      Value<double?>? deepSleepFragmentation,
      Value<double?>? lightSleepFragmentation,
      Value<double?>? remSleepFragmentation,
      Value<DateTime>? date,
      Value<String?>? notes}) {
    return AdvancedSleepMeasurementsCompanion(
      id: id ?? this.id,
      timeInBed: timeInBed ?? this.timeInBed,
      totalAwakeTime: totalAwakeTime ?? this.totalAwakeTime,
      numberOfAwakenings: numberOfAwakenings ?? this.numberOfAwakenings,
      longestAwakePeriod: longestAwakePeriod ?? this.longestAwakePeriod,
      sleepLatency: sleepLatency ?? this.sleepLatency,
      deepSleepLatency: deepSleepLatency ?? this.deepSleepLatency,
      remSleepLatency: remSleepLatency ?? this.remSleepLatency,
      deepSleepFragmentation:
          deepSleepFragmentation ?? this.deepSleepFragmentation,
      lightSleepFragmentation:
          lightSleepFragmentation ?? this.lightSleepFragmentation,
      remSleepFragmentation:
          remSleepFragmentation ?? this.remSleepFragmentation,
      date: date ?? this.date,
      notes: notes ?? this.notes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (timeInBed.present) {
      map['timeInBed'] = Variable<double>(timeInBed.value);
    }
    if (totalAwakeTime.present) {
      map['totalAwakeTime'] = Variable<double>(totalAwakeTime.value);
    }
    if (numberOfAwakenings.present) {
      map['numberOfAwakenings'] = Variable<int>(numberOfAwakenings.value);
    }
    if (longestAwakePeriod.present) {
      map['longestAwakePeriod'] = Variable<double>(longestAwakePeriod.value);
    }
    if (sleepLatency.present) {
      map['sleepLatency'] = Variable<double>(sleepLatency.value);
    }
    if (deepSleepLatency.present) {
      map['deepSleepLatency'] = Variable<double>(deepSleepLatency.value);
    }
    if (remSleepLatency.present) {
      map['remSleepLatency'] = Variable<double>(remSleepLatency.value);
    }
    if (deepSleepFragmentation.present) {
      map['deepSleepFragmentation'] =
          Variable<double>(deepSleepFragmentation.value);
    }
    if (lightSleepFragmentation.present) {
      map['lightSleepFragmentation'] =
          Variable<double>(lightSleepFragmentation.value);
    }
    if (remSleepFragmentation.present) {
      map['remSleepFragmentation'] =
          Variable<double>(remSleepFragmentation.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(
          $AdvancedSleepMeasurementsTable.$converterdate.toSql(date.value));
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AdvancedSleepMeasurementsCompanion(')
          ..write('id: $id, ')
          ..write('timeInBed: $timeInBed, ')
          ..write('totalAwakeTime: $totalAwakeTime, ')
          ..write('numberOfAwakenings: $numberOfAwakenings, ')
          ..write('longestAwakePeriod: $longestAwakePeriod, ')
          ..write('sleepLatency: $sleepLatency, ')
          ..write('deepSleepLatency: $deepSleepLatency, ')
          ..write('remSleepLatency: $remSleepLatency, ')
          ..write('deepSleepFragmentation: $deepSleepFragmentation, ')
          ..write('lightSleepFragmentation: $lightSleepFragmentation, ')
          ..write('remSleepFragmentation: $remSleepFragmentation, ')
          ..write('date: $date, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }
}

class $ProductsTable extends Products with TableInfo<$ProductsTable, Product> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _weightMeta = const VerificationMeta('weight');
  @override
  late final GeneratedColumn<double> weight = GeneratedColumn<double>(
      'weight', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _mlToGFactorMeta =
      const VerificationMeta('mlToGFactor');
  @override
  late final GeneratedColumn<int> mlToGFactor = GeneratedColumn<int>(
      'mlToGFactor', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _unitWeightMeta =
      const VerificationMeta('unitWeight');
  @override
  late final GeneratedColumn<int> unitWeight = GeneratedColumn<int>(
      'unitWeight', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _defaultUnitsMeta =
      const VerificationMeta('defaultUnits');
  @override
  late final GeneratedColumn<String> defaultUnits = GeneratedColumn<String>(
      'defaultUnits', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _edibleQtyPerUnitMeta =
      const VerificationMeta('edibleQtyPerUnit');
  @override
  late final GeneratedColumn<double> edibleQtyPerUnit = GeneratedColumn<double>(
      'edibleQtyPerUnit', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _kcalMeta = const VerificationMeta('kcal');
  @override
  late final GeneratedColumn<double> kcal = GeneratedColumn<double>(
      'kcal', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _proteinsMeta =
      const VerificationMeta('proteins');
  @override
  late final GeneratedColumn<double> proteins = GeneratedColumn<double>(
      'proteins', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _carbsByDifferenceMeta =
      const VerificationMeta('carbsByDifference');
  @override
  late final GeneratedColumn<double> carbsByDifference =
      GeneratedColumn<double>('carbsByDifference', aliasedName, true,
          type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _carbsAvailableMeta =
      const VerificationMeta('carbsAvailable');
  @override
  late final GeneratedColumn<double> carbsAvailable = GeneratedColumn<double>(
      'carbsAvailable', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _dietaryFiberMeta =
      const VerificationMeta('dietaryFiber');
  @override
  late final GeneratedColumn<double> dietaryFiber = GeneratedColumn<double>(
      'dietaryFiber', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _fatsMeta = const VerificationMeta('fats');
  @override
  late final GeneratedColumn<double> fats = GeneratedColumn<double>(
      'fats', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _isSupplementMeta =
      const VerificationMeta('isSupplement');
  @override
  late final GeneratedColumn<bool> isSupplement = GeneratedColumn<bool>(
      'isSupplement', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("isSupplement" IN (0, 1))'));
  static const VerificationMeta _isPortableMeta =
      const VerificationMeta('isPortable');
  @override
  late final GeneratedColumn<bool> isPortable = GeneratedColumn<bool>(
      'isPortable', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("isPortable" IN (0, 1))'),
      defaultValue: const Constant(true));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        weight,
        mlToGFactor,
        unitWeight,
        defaultUnits,
        edibleQtyPerUnit,
        kcal,
        proteins,
        carbsByDifference,
        carbsAvailable,
        dietaryFiber,
        fats,
        isSupplement,
        isPortable
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'products';
  @override
  VerificationContext validateIntegrity(Insertable<Product> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('weight')) {
      context.handle(_weightMeta,
          weight.isAcceptableOrUnknown(data['weight']!, _weightMeta));
    } else if (isInserting) {
      context.missing(_weightMeta);
    }
    if (data.containsKey('mlToGFactor')) {
      context.handle(
          _mlToGFactorMeta,
          mlToGFactor.isAcceptableOrUnknown(
              data['mlToGFactor']!, _mlToGFactorMeta));
    }
    if (data.containsKey('unitWeight')) {
      context.handle(
          _unitWeightMeta,
          unitWeight.isAcceptableOrUnknown(
              data['unitWeight']!, _unitWeightMeta));
    }
    if (data.containsKey('defaultUnits')) {
      context.handle(
          _defaultUnitsMeta,
          defaultUnits.isAcceptableOrUnknown(
              data['defaultUnits']!, _defaultUnitsMeta));
    }
    if (data.containsKey('edibleQtyPerUnit')) {
      context.handle(
          _edibleQtyPerUnitMeta,
          edibleQtyPerUnit.isAcceptableOrUnknown(
              data['edibleQtyPerUnit']!, _edibleQtyPerUnitMeta));
    }
    if (data.containsKey('kcal')) {
      context.handle(
          _kcalMeta, kcal.isAcceptableOrUnknown(data['kcal']!, _kcalMeta));
    }
    if (data.containsKey('proteins')) {
      context.handle(_proteinsMeta,
          proteins.isAcceptableOrUnknown(data['proteins']!, _proteinsMeta));
    } else if (isInserting) {
      context.missing(_proteinsMeta);
    }
    if (data.containsKey('carbsByDifference')) {
      context.handle(
          _carbsByDifferenceMeta,
          carbsByDifference.isAcceptableOrUnknown(
              data['carbsByDifference']!, _carbsByDifferenceMeta));
    }
    if (data.containsKey('carbsAvailable')) {
      context.handle(
          _carbsAvailableMeta,
          carbsAvailable.isAcceptableOrUnknown(
              data['carbsAvailable']!, _carbsAvailableMeta));
    }
    if (data.containsKey('dietaryFiber')) {
      context.handle(
          _dietaryFiberMeta,
          dietaryFiber.isAcceptableOrUnknown(
              data['dietaryFiber']!, _dietaryFiberMeta));
    }
    if (data.containsKey('fats')) {
      context.handle(
          _fatsMeta, fats.isAcceptableOrUnknown(data['fats']!, _fatsMeta));
    } else if (isInserting) {
      context.missing(_fatsMeta);
    }
    if (data.containsKey('isSupplement')) {
      context.handle(
          _isSupplementMeta,
          isSupplement.isAcceptableOrUnknown(
              data['isSupplement']!, _isSupplementMeta));
    } else if (isInserting) {
      context.missing(_isSupplementMeta);
    }
    if (data.containsKey('isPortable')) {
      context.handle(
          _isPortableMeta,
          isPortable.isAcceptableOrUnknown(
              data['isPortable']!, _isPortableMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Product map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Product(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      weight: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}weight'])!,
      mlToGFactor: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}mlToGFactor']),
      unitWeight: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}unitWeight']),
      defaultUnits: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}defaultUnits']),
      edibleQtyPerUnit: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}edibleQtyPerUnit']),
      kcal: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}kcal']),
      proteins: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}proteins'])!,
      carbsByDifference: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}carbsByDifference']),
      carbsAvailable: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}carbsAvailable']),
      dietaryFiber: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}dietaryFiber']),
      fats: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}fats'])!,
      isSupplement: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}isSupplement'])!,
      isPortable: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}isPortable'])!,
    );
  }

  @override
  $ProductsTable createAlias(String alias) {
    return $ProductsTable(attachedDatabase, alias);
  }
}

class Product extends DataClass implements Insertable<Product> {
  final int id;
  final String name;
  final double weight;
  final int? mlToGFactor;
  final int? unitWeight;
  final String? defaultUnits;
  final double? edibleQtyPerUnit;
  final double? kcal;
  final double proteins;
  final double? carbsByDifference;
  final double? carbsAvailable;
  final double? dietaryFiber;
  final double fats;
  final bool isSupplement;
  final bool isPortable;
  const Product(
      {required this.id,
      required this.name,
      required this.weight,
      this.mlToGFactor,
      this.unitWeight,
      this.defaultUnits,
      this.edibleQtyPerUnit,
      this.kcal,
      required this.proteins,
      this.carbsByDifference,
      this.carbsAvailable,
      this.dietaryFiber,
      required this.fats,
      required this.isSupplement,
      required this.isPortable});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['weight'] = Variable<double>(weight);
    if (!nullToAbsent || mlToGFactor != null) {
      map['mlToGFactor'] = Variable<int>(mlToGFactor);
    }
    if (!nullToAbsent || unitWeight != null) {
      map['unitWeight'] = Variable<int>(unitWeight);
    }
    if (!nullToAbsent || defaultUnits != null) {
      map['defaultUnits'] = Variable<String>(defaultUnits);
    }
    if (!nullToAbsent || edibleQtyPerUnit != null) {
      map['edibleQtyPerUnit'] = Variable<double>(edibleQtyPerUnit);
    }
    if (!nullToAbsent || kcal != null) {
      map['kcal'] = Variable<double>(kcal);
    }
    map['proteins'] = Variable<double>(proteins);
    if (!nullToAbsent || carbsByDifference != null) {
      map['carbsByDifference'] = Variable<double>(carbsByDifference);
    }
    if (!nullToAbsent || carbsAvailable != null) {
      map['carbsAvailable'] = Variable<double>(carbsAvailable);
    }
    if (!nullToAbsent || dietaryFiber != null) {
      map['dietaryFiber'] = Variable<double>(dietaryFiber);
    }
    map['fats'] = Variable<double>(fats);
    map['isSupplement'] = Variable<bool>(isSupplement);
    map['isPortable'] = Variable<bool>(isPortable);
    return map;
  }

  ProductsCompanion toCompanion(bool nullToAbsent) {
    return ProductsCompanion(
      id: Value(id),
      name: Value(name),
      weight: Value(weight),
      mlToGFactor: mlToGFactor == null && nullToAbsent
          ? const Value.absent()
          : Value(mlToGFactor),
      unitWeight: unitWeight == null && nullToAbsent
          ? const Value.absent()
          : Value(unitWeight),
      defaultUnits: defaultUnits == null && nullToAbsent
          ? const Value.absent()
          : Value(defaultUnits),
      edibleQtyPerUnit: edibleQtyPerUnit == null && nullToAbsent
          ? const Value.absent()
          : Value(edibleQtyPerUnit),
      kcal: kcal == null && nullToAbsent ? const Value.absent() : Value(kcal),
      proteins: Value(proteins),
      carbsByDifference: carbsByDifference == null && nullToAbsent
          ? const Value.absent()
          : Value(carbsByDifference),
      carbsAvailable: carbsAvailable == null && nullToAbsent
          ? const Value.absent()
          : Value(carbsAvailable),
      dietaryFiber: dietaryFiber == null && nullToAbsent
          ? const Value.absent()
          : Value(dietaryFiber),
      fats: Value(fats),
      isSupplement: Value(isSupplement),
      isPortable: Value(isPortable),
    );
  }

  factory Product.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Product(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      weight: serializer.fromJson<double>(json['weight']),
      mlToGFactor: serializer.fromJson<int?>(json['mlToGFactor']),
      unitWeight: serializer.fromJson<int?>(json['unitWeight']),
      defaultUnits: serializer.fromJson<String?>(json['defaultUnits']),
      edibleQtyPerUnit: serializer.fromJson<double?>(json['edibleQtyPerUnit']),
      kcal: serializer.fromJson<double?>(json['kcal']),
      proteins: serializer.fromJson<double>(json['proteins']),
      carbsByDifference:
          serializer.fromJson<double?>(json['carbsByDifference']),
      carbsAvailable: serializer.fromJson<double?>(json['carbsAvailable']),
      dietaryFiber: serializer.fromJson<double?>(json['dietaryFiber']),
      fats: serializer.fromJson<double>(json['fats']),
      isSupplement: serializer.fromJson<bool>(json['isSupplement']),
      isPortable: serializer.fromJson<bool>(json['isPortable']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'weight': serializer.toJson<double>(weight),
      'mlToGFactor': serializer.toJson<int?>(mlToGFactor),
      'unitWeight': serializer.toJson<int?>(unitWeight),
      'defaultUnits': serializer.toJson<String?>(defaultUnits),
      'edibleQtyPerUnit': serializer.toJson<double?>(edibleQtyPerUnit),
      'kcal': serializer.toJson<double?>(kcal),
      'proteins': serializer.toJson<double>(proteins),
      'carbsByDifference': serializer.toJson<double?>(carbsByDifference),
      'carbsAvailable': serializer.toJson<double?>(carbsAvailable),
      'dietaryFiber': serializer.toJson<double?>(dietaryFiber),
      'fats': serializer.toJson<double>(fats),
      'isSupplement': serializer.toJson<bool>(isSupplement),
      'isPortable': serializer.toJson<bool>(isPortable),
    };
  }

  Product copyWith(
          {int? id,
          String? name,
          double? weight,
          Value<int?> mlToGFactor = const Value.absent(),
          Value<int?> unitWeight = const Value.absent(),
          Value<String?> defaultUnits = const Value.absent(),
          Value<double?> edibleQtyPerUnit = const Value.absent(),
          Value<double?> kcal = const Value.absent(),
          double? proteins,
          Value<double?> carbsByDifference = const Value.absent(),
          Value<double?> carbsAvailable = const Value.absent(),
          Value<double?> dietaryFiber = const Value.absent(),
          double? fats,
          bool? isSupplement,
          bool? isPortable}) =>
      Product(
        id: id ?? this.id,
        name: name ?? this.name,
        weight: weight ?? this.weight,
        mlToGFactor: mlToGFactor.present ? mlToGFactor.value : this.mlToGFactor,
        unitWeight: unitWeight.present ? unitWeight.value : this.unitWeight,
        defaultUnits:
            defaultUnits.present ? defaultUnits.value : this.defaultUnits,
        edibleQtyPerUnit: edibleQtyPerUnit.present
            ? edibleQtyPerUnit.value
            : this.edibleQtyPerUnit,
        kcal: kcal.present ? kcal.value : this.kcal,
        proteins: proteins ?? this.proteins,
        carbsByDifference: carbsByDifference.present
            ? carbsByDifference.value
            : this.carbsByDifference,
        carbsAvailable:
            carbsAvailable.present ? carbsAvailable.value : this.carbsAvailable,
        dietaryFiber:
            dietaryFiber.present ? dietaryFiber.value : this.dietaryFiber,
        fats: fats ?? this.fats,
        isSupplement: isSupplement ?? this.isSupplement,
        isPortable: isPortable ?? this.isPortable,
      );
  @override
  String toString() {
    return (StringBuffer('Product(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('weight: $weight, ')
          ..write('mlToGFactor: $mlToGFactor, ')
          ..write('unitWeight: $unitWeight, ')
          ..write('defaultUnits: $defaultUnits, ')
          ..write('edibleQtyPerUnit: $edibleQtyPerUnit, ')
          ..write('kcal: $kcal, ')
          ..write('proteins: $proteins, ')
          ..write('carbsByDifference: $carbsByDifference, ')
          ..write('carbsAvailable: $carbsAvailable, ')
          ..write('dietaryFiber: $dietaryFiber, ')
          ..write('fats: $fats, ')
          ..write('isSupplement: $isSupplement, ')
          ..write('isPortable: $isPortable')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      name,
      weight,
      mlToGFactor,
      unitWeight,
      defaultUnits,
      edibleQtyPerUnit,
      kcal,
      proteins,
      carbsByDifference,
      carbsAvailable,
      dietaryFiber,
      fats,
      isSupplement,
      isPortable);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Product &&
          other.id == this.id &&
          other.name == this.name &&
          other.weight == this.weight &&
          other.mlToGFactor == this.mlToGFactor &&
          other.unitWeight == this.unitWeight &&
          other.defaultUnits == this.defaultUnits &&
          other.edibleQtyPerUnit == this.edibleQtyPerUnit &&
          other.kcal == this.kcal &&
          other.proteins == this.proteins &&
          other.carbsByDifference == this.carbsByDifference &&
          other.carbsAvailable == this.carbsAvailable &&
          other.dietaryFiber == this.dietaryFiber &&
          other.fats == this.fats &&
          other.isSupplement == this.isSupplement &&
          other.isPortable == this.isPortable);
}

class ProductsCompanion extends UpdateCompanion<Product> {
  final Value<int> id;
  final Value<String> name;
  final Value<double> weight;
  final Value<int?> mlToGFactor;
  final Value<int?> unitWeight;
  final Value<String?> defaultUnits;
  final Value<double?> edibleQtyPerUnit;
  final Value<double?> kcal;
  final Value<double> proteins;
  final Value<double?> carbsByDifference;
  final Value<double?> carbsAvailable;
  final Value<double?> dietaryFiber;
  final Value<double> fats;
  final Value<bool> isSupplement;
  final Value<bool> isPortable;
  const ProductsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.weight = const Value.absent(),
    this.mlToGFactor = const Value.absent(),
    this.unitWeight = const Value.absent(),
    this.defaultUnits = const Value.absent(),
    this.edibleQtyPerUnit = const Value.absent(),
    this.kcal = const Value.absent(),
    this.proteins = const Value.absent(),
    this.carbsByDifference = const Value.absent(),
    this.carbsAvailable = const Value.absent(),
    this.dietaryFiber = const Value.absent(),
    this.fats = const Value.absent(),
    this.isSupplement = const Value.absent(),
    this.isPortable = const Value.absent(),
  });
  ProductsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required double weight,
    this.mlToGFactor = const Value.absent(),
    this.unitWeight = const Value.absent(),
    this.defaultUnits = const Value.absent(),
    this.edibleQtyPerUnit = const Value.absent(),
    this.kcal = const Value.absent(),
    required double proteins,
    this.carbsByDifference = const Value.absent(),
    this.carbsAvailable = const Value.absent(),
    this.dietaryFiber = const Value.absent(),
    required double fats,
    required bool isSupplement,
    this.isPortable = const Value.absent(),
  })  : name = Value(name),
        weight = Value(weight),
        proteins = Value(proteins),
        fats = Value(fats),
        isSupplement = Value(isSupplement);
  static Insertable<Product> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<double>? weight,
    Expression<int>? mlToGFactor,
    Expression<int>? unitWeight,
    Expression<String>? defaultUnits,
    Expression<double>? edibleQtyPerUnit,
    Expression<double>? kcal,
    Expression<double>? proteins,
    Expression<double>? carbsByDifference,
    Expression<double>? carbsAvailable,
    Expression<double>? dietaryFiber,
    Expression<double>? fats,
    Expression<bool>? isSupplement,
    Expression<bool>? isPortable,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (weight != null) 'weight': weight,
      if (mlToGFactor != null) 'mlToGFactor': mlToGFactor,
      if (unitWeight != null) 'unitWeight': unitWeight,
      if (defaultUnits != null) 'defaultUnits': defaultUnits,
      if (edibleQtyPerUnit != null) 'edibleQtyPerUnit': edibleQtyPerUnit,
      if (kcal != null) 'kcal': kcal,
      if (proteins != null) 'proteins': proteins,
      if (carbsByDifference != null) 'carbsByDifference': carbsByDifference,
      if (carbsAvailable != null) 'carbsAvailable': carbsAvailable,
      if (dietaryFiber != null) 'dietaryFiber': dietaryFiber,
      if (fats != null) 'fats': fats,
      if (isSupplement != null) 'isSupplement': isSupplement,
      if (isPortable != null) 'isPortable': isPortable,
    });
  }

  ProductsCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<double>? weight,
      Value<int?>? mlToGFactor,
      Value<int?>? unitWeight,
      Value<String?>? defaultUnits,
      Value<double?>? edibleQtyPerUnit,
      Value<double?>? kcal,
      Value<double>? proteins,
      Value<double?>? carbsByDifference,
      Value<double?>? carbsAvailable,
      Value<double?>? dietaryFiber,
      Value<double>? fats,
      Value<bool>? isSupplement,
      Value<bool>? isPortable}) {
    return ProductsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      weight: weight ?? this.weight,
      mlToGFactor: mlToGFactor ?? this.mlToGFactor,
      unitWeight: unitWeight ?? this.unitWeight,
      defaultUnits: defaultUnits ?? this.defaultUnits,
      edibleQtyPerUnit: edibleQtyPerUnit ?? this.edibleQtyPerUnit,
      kcal: kcal ?? this.kcal,
      proteins: proteins ?? this.proteins,
      carbsByDifference: carbsByDifference ?? this.carbsByDifference,
      carbsAvailable: carbsAvailable ?? this.carbsAvailable,
      dietaryFiber: dietaryFiber ?? this.dietaryFiber,
      fats: fats ?? this.fats,
      isSupplement: isSupplement ?? this.isSupplement,
      isPortable: isPortable ?? this.isPortable,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (weight.present) {
      map['weight'] = Variable<double>(weight.value);
    }
    if (mlToGFactor.present) {
      map['mlToGFactor'] = Variable<int>(mlToGFactor.value);
    }
    if (unitWeight.present) {
      map['unitWeight'] = Variable<int>(unitWeight.value);
    }
    if (defaultUnits.present) {
      map['defaultUnits'] = Variable<String>(defaultUnits.value);
    }
    if (edibleQtyPerUnit.present) {
      map['edibleQtyPerUnit'] = Variable<double>(edibleQtyPerUnit.value);
    }
    if (kcal.present) {
      map['kcal'] = Variable<double>(kcal.value);
    }
    if (proteins.present) {
      map['proteins'] = Variable<double>(proteins.value);
    }
    if (carbsByDifference.present) {
      map['carbsByDifference'] = Variable<double>(carbsByDifference.value);
    }
    if (carbsAvailable.present) {
      map['carbsAvailable'] = Variable<double>(carbsAvailable.value);
    }
    if (dietaryFiber.present) {
      map['dietaryFiber'] = Variable<double>(dietaryFiber.value);
    }
    if (fats.present) {
      map['fats'] = Variable<double>(fats.value);
    }
    if (isSupplement.present) {
      map['isSupplement'] = Variable<bool>(isSupplement.value);
    }
    if (isPortable.present) {
      map['isPortable'] = Variable<bool>(isPortable.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('weight: $weight, ')
          ..write('mlToGFactor: $mlToGFactor, ')
          ..write('unitWeight: $unitWeight, ')
          ..write('defaultUnits: $defaultUnits, ')
          ..write('edibleQtyPerUnit: $edibleQtyPerUnit, ')
          ..write('kcal: $kcal, ')
          ..write('proteins: $proteins, ')
          ..write('carbsByDifference: $carbsByDifference, ')
          ..write('carbsAvailable: $carbsAvailable, ')
          ..write('dietaryFiber: $dietaryFiber, ')
          ..write('fats: $fats, ')
          ..write('isSupplement: $isSupplement, ')
          ..write('isPortable: $isPortable')
          ..write(')'))
        .toString();
  }
}

class $RecipesTable extends Recipes with TableInfo<$RecipesTable, Recipe> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecipesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _instructionsMeta =
      const VerificationMeta('instructions');
  @override
  late final GeneratedColumn<String> instructions = GeneratedColumn<String>(
      'instructions', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isPortableMeta =
      const VerificationMeta('isPortable');
  @override
  late final GeneratedColumn<bool> isPortable = GeneratedColumn<bool>(
      'isPortable', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("isPortable" IN (0, 1))'));
  @override
  List<GeneratedColumn> get $columns => [id, name, instructions, isPortable];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recipes';
  @override
  VerificationContext validateIntegrity(Insertable<Recipe> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('instructions')) {
      context.handle(
          _instructionsMeta,
          instructions.isAcceptableOrUnknown(
              data['instructions']!, _instructionsMeta));
    } else if (isInserting) {
      context.missing(_instructionsMeta);
    }
    if (data.containsKey('isPortable')) {
      context.handle(
          _isPortableMeta,
          isPortable.isAcceptableOrUnknown(
              data['isPortable']!, _isPortableMeta));
    } else if (isInserting) {
      context.missing(_isPortableMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Recipe map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Recipe(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      instructions: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}instructions'])!,
      isPortable: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}isPortable'])!,
    );
  }

  @override
  $RecipesTable createAlias(String alias) {
    return $RecipesTable(attachedDatabase, alias);
  }
}

class Recipe extends DataClass implements Insertable<Recipe> {
  final int id;
  final String name;
  final String instructions;
  final bool isPortable;
  const Recipe(
      {required this.id,
      required this.name,
      required this.instructions,
      required this.isPortable});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['instructions'] = Variable<String>(instructions);
    map['isPortable'] = Variable<bool>(isPortable);
    return map;
  }

  RecipesCompanion toCompanion(bool nullToAbsent) {
    return RecipesCompanion(
      id: Value(id),
      name: Value(name),
      instructions: Value(instructions),
      isPortable: Value(isPortable),
    );
  }

  factory Recipe.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Recipe(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      instructions: serializer.fromJson<String>(json['instructions']),
      isPortable: serializer.fromJson<bool>(json['isPortable']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'instructions': serializer.toJson<String>(instructions),
      'isPortable': serializer.toJson<bool>(isPortable),
    };
  }

  Recipe copyWith(
          {int? id, String? name, String? instructions, bool? isPortable}) =>
      Recipe(
        id: id ?? this.id,
        name: name ?? this.name,
        instructions: instructions ?? this.instructions,
        isPortable: isPortable ?? this.isPortable,
      );
  @override
  String toString() {
    return (StringBuffer('Recipe(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('instructions: $instructions, ')
          ..write('isPortable: $isPortable')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, instructions, isPortable);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Recipe &&
          other.id == this.id &&
          other.name == this.name &&
          other.instructions == this.instructions &&
          other.isPortable == this.isPortable);
}

class RecipesCompanion extends UpdateCompanion<Recipe> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> instructions;
  final Value<bool> isPortable;
  const RecipesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.instructions = const Value.absent(),
    this.isPortable = const Value.absent(),
  });
  RecipesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String instructions,
    required bool isPortable,
  })  : name = Value(name),
        instructions = Value(instructions),
        isPortable = Value(isPortable);
  static Insertable<Recipe> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? instructions,
    Expression<bool>? isPortable,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (instructions != null) 'instructions': instructions,
      if (isPortable != null) 'isPortable': isPortable,
    });
  }

  RecipesCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String>? instructions,
      Value<bool>? isPortable}) {
    return RecipesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      instructions: instructions ?? this.instructions,
      isPortable: isPortable ?? this.isPortable,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (instructions.present) {
      map['instructions'] = Variable<String>(instructions.value);
    }
    if (isPortable.present) {
      map['isPortable'] = Variable<bool>(isPortable.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecipesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('instructions: $instructions, ')
          ..write('isPortable: $isPortable')
          ..write(')'))
        .toString();
  }
}

class $RecipeIngredientsTable extends RecipeIngredients
    with TableInfo<$RecipeIngredientsTable, RecipeIngredient> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecipeIngredientsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _recipeIdMeta =
      const VerificationMeta('recipeId');
  @override
  late final GeneratedColumn<int> recipeId = GeneratedColumn<int>(
      'recipeId', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _productIdMeta =
      const VerificationMeta('productId');
  @override
  late final GeneratedColumn<int> productId = GeneratedColumn<int>(
      'productId', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _amountUnitsMeta =
      const VerificationMeta('amountUnits');
  @override
  late final GeneratedColumn<String> amountUnits = GeneratedColumn<String>(
      'amountUnits', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, recipeId, productId, amount, amountUnits];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recipe_ingredients';
  @override
  VerificationContext validateIntegrity(Insertable<RecipeIngredient> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('recipeId')) {
      context.handle(_recipeIdMeta,
          recipeId.isAcceptableOrUnknown(data['recipeId']!, _recipeIdMeta));
    } else if (isInserting) {
      context.missing(_recipeIdMeta);
    }
    if (data.containsKey('productId')) {
      context.handle(_productIdMeta,
          productId.isAcceptableOrUnknown(data['productId']!, _productIdMeta));
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('amountUnits')) {
      context.handle(
          _amountUnitsMeta,
          amountUnits.isAcceptableOrUnknown(
              data['amountUnits']!, _amountUnitsMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecipeIngredient map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecipeIngredient(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      recipeId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}recipeId'])!,
      productId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}productId'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      amountUnits: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}amountUnits']),
    );
  }

  @override
  $RecipeIngredientsTable createAlias(String alias) {
    return $RecipeIngredientsTable(attachedDatabase, alias);
  }
}

class RecipeIngredient extends DataClass
    implements Insertable<RecipeIngredient> {
  final int id;
  final int recipeId;
  final int productId;
  final double amount;
  final String? amountUnits;
  const RecipeIngredient(
      {required this.id,
      required this.recipeId,
      required this.productId,
      required this.amount,
      this.amountUnits});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['recipeId'] = Variable<int>(recipeId);
    map['productId'] = Variable<int>(productId);
    map['amount'] = Variable<double>(amount);
    if (!nullToAbsent || amountUnits != null) {
      map['amountUnits'] = Variable<String>(amountUnits);
    }
    return map;
  }

  RecipeIngredientsCompanion toCompanion(bool nullToAbsent) {
    return RecipeIngredientsCompanion(
      id: Value(id),
      recipeId: Value(recipeId),
      productId: Value(productId),
      amount: Value(amount),
      amountUnits: amountUnits == null && nullToAbsent
          ? const Value.absent()
          : Value(amountUnits),
    );
  }

  factory RecipeIngredient.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecipeIngredient(
      id: serializer.fromJson<int>(json['id']),
      recipeId: serializer.fromJson<int>(json['recipeId']),
      productId: serializer.fromJson<int>(json['productId']),
      amount: serializer.fromJson<double>(json['amount']),
      amountUnits: serializer.fromJson<String?>(json['amountUnits']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'recipeId': serializer.toJson<int>(recipeId),
      'productId': serializer.toJson<int>(productId),
      'amount': serializer.toJson<double>(amount),
      'amountUnits': serializer.toJson<String?>(amountUnits),
    };
  }

  RecipeIngredient copyWith(
          {int? id,
          int? recipeId,
          int? productId,
          double? amount,
          Value<String?> amountUnits = const Value.absent()}) =>
      RecipeIngredient(
        id: id ?? this.id,
        recipeId: recipeId ?? this.recipeId,
        productId: productId ?? this.productId,
        amount: amount ?? this.amount,
        amountUnits: amountUnits.present ? amountUnits.value : this.amountUnits,
      );
  @override
  String toString() {
    return (StringBuffer('RecipeIngredient(')
          ..write('id: $id, ')
          ..write('recipeId: $recipeId, ')
          ..write('productId: $productId, ')
          ..write('amount: $amount, ')
          ..write('amountUnits: $amountUnits')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, recipeId, productId, amount, amountUnits);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecipeIngredient &&
          other.id == this.id &&
          other.recipeId == this.recipeId &&
          other.productId == this.productId &&
          other.amount == this.amount &&
          other.amountUnits == this.amountUnits);
}

class RecipeIngredientsCompanion extends UpdateCompanion<RecipeIngredient> {
  final Value<int> id;
  final Value<int> recipeId;
  final Value<int> productId;
  final Value<double> amount;
  final Value<String?> amountUnits;
  const RecipeIngredientsCompanion({
    this.id = const Value.absent(),
    this.recipeId = const Value.absent(),
    this.productId = const Value.absent(),
    this.amount = const Value.absent(),
    this.amountUnits = const Value.absent(),
  });
  RecipeIngredientsCompanion.insert({
    this.id = const Value.absent(),
    required int recipeId,
    required int productId,
    required double amount,
    this.amountUnits = const Value.absent(),
  })  : recipeId = Value(recipeId),
        productId = Value(productId),
        amount = Value(amount);
  static Insertable<RecipeIngredient> custom({
    Expression<int>? id,
    Expression<int>? recipeId,
    Expression<int>? productId,
    Expression<double>? amount,
    Expression<String>? amountUnits,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (recipeId != null) 'recipeId': recipeId,
      if (productId != null) 'productId': productId,
      if (amount != null) 'amount': amount,
      if (amountUnits != null) 'amountUnits': amountUnits,
    });
  }

  RecipeIngredientsCompanion copyWith(
      {Value<int>? id,
      Value<int>? recipeId,
      Value<int>? productId,
      Value<double>? amount,
      Value<String?>? amountUnits}) {
    return RecipeIngredientsCompanion(
      id: id ?? this.id,
      recipeId: recipeId ?? this.recipeId,
      productId: productId ?? this.productId,
      amount: amount ?? this.amount,
      amountUnits: amountUnits ?? this.amountUnits,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (recipeId.present) {
      map['recipeId'] = Variable<int>(recipeId.value);
    }
    if (productId.present) {
      map['productId'] = Variable<int>(productId.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (amountUnits.present) {
      map['amountUnits'] = Variable<String>(amountUnits.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecipeIngredientsCompanion(')
          ..write('id: $id, ')
          ..write('recipeId: $recipeId, ')
          ..write('productId: $productId, ')
          ..write('amount: $amount, ')
          ..write('amountUnits: $amountUnits')
          ..write(')'))
        .toString();
  }
}

class $MealPlansTable extends MealPlans
    with TableInfo<$MealPlansTable, MealPlan> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MealPlansTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _parentPlanIdMeta =
      const VerificationMeta('parentPlanId');
  @override
  late final GeneratedColumn<int> parentPlanId = GeneratedColumn<int>(
      'parentPlanId', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumnWithTypeConverter<MealPlanState, String> state =
      GeneratedColumn<String>('state', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<MealPlanState>($MealPlansTable.$converterstate);
  static const VerificationMeta _createdMeta =
      const VerificationMeta('created');
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> created =
      GeneratedColumn<String>('created', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<DateTime>($MealPlansTable.$convertercreated);
  static const VerificationMeta _completedMeta =
      const VerificationMeta('completed');
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> completed =
      GeneratedColumn<String>('completed', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<DateTime>($MealPlansTable.$convertercompleted);
  static const VerificationMeta _targetProteinMeta =
      const VerificationMeta('targetProtein');
  @override
  late final GeneratedColumn<double> targetProtein = GeneratedColumn<double>(
      'target_protein', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _targetCarbsMeta =
      const VerificationMeta('targetCarbs');
  @override
  late final GeneratedColumn<double> targetCarbs = GeneratedColumn<double>(
      'target_carbs', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _targetFatsMeta =
      const VerificationMeta('targetFats');
  @override
  late final GeneratedColumn<double> targetFats = GeneratedColumn<double>(
      'target_fats', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _isTemporalMeta =
      const VerificationMeta('isTemporal');
  @override
  late final GeneratedColumn<bool> isTemporal = GeneratedColumn<bool>(
      'isTemporal', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("isTemporal" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        parentPlanId,
        title,
        notes,
        state,
        created,
        completed,
        targetProtein,
        targetCarbs,
        targetFats,
        isTemporal
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'meal_plans';
  @override
  VerificationContext validateIntegrity(Insertable<MealPlan> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('parentPlanId')) {
      context.handle(
          _parentPlanIdMeta,
          parentPlanId.isAcceptableOrUnknown(
              data['parentPlanId']!, _parentPlanIdMeta));
    } else if (isInserting) {
      context.missing(_parentPlanIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    } else if (isInserting) {
      context.missing(_notesMeta);
    }
    context.handle(_stateMeta, const VerificationResult.success());
    context.handle(_createdMeta, const VerificationResult.success());
    context.handle(_completedMeta, const VerificationResult.success());
    if (data.containsKey('target_protein')) {
      context.handle(
          _targetProteinMeta,
          targetProtein.isAcceptableOrUnknown(
              data['target_protein']!, _targetProteinMeta));
    }
    if (data.containsKey('target_carbs')) {
      context.handle(
          _targetCarbsMeta,
          targetCarbs.isAcceptableOrUnknown(
              data['target_carbs']!, _targetCarbsMeta));
    }
    if (data.containsKey('target_fats')) {
      context.handle(
          _targetFatsMeta,
          targetFats.isAcceptableOrUnknown(
              data['target_fats']!, _targetFatsMeta));
    }
    if (data.containsKey('isTemporal')) {
      context.handle(
          _isTemporalMeta,
          isTemporal.isAcceptableOrUnknown(
              data['isTemporal']!, _isTemporalMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MealPlan map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MealPlan(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      parentPlanId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}parentPlanId'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes'])!,
      state: $MealPlansTable.$converterstate.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}state'])!),
      created: $MealPlansTable.$convertercreated.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created'])!),
      completed: $MealPlansTable.$convertercompleted.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}completed'])!),
      targetProtein: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}target_protein']),
      targetCarbs: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}target_carbs']),
      targetFats: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}target_fats']),
      isTemporal: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}isTemporal'])!,
    );
  }

  @override
  $MealPlansTable createAlias(String alias) {
    return $MealPlansTable(attachedDatabase, alias);
  }

  static TypeConverter<MealPlanState, String> $converterstate =
      const EnumNameConverter(MealPlanState.values);
  static TypeConverter<DateTime, String> $convertercreated =
      const IsoDateTimeConverter();
  static TypeConverter<DateTime, String> $convertercompleted =
      const IsoDateTimeConverter();
}

class MealPlan extends DataClass implements Insertable<MealPlan> {
  final int id;
  final int parentPlanId;
  final String title;
  final String notes;
  final MealPlanState state;
  final DateTime created;
  final DateTime completed;
  final double? targetProtein;
  final double? targetCarbs;
  final double? targetFats;
  final bool isTemporal;
  const MealPlan(
      {required this.id,
      required this.parentPlanId,
      required this.title,
      required this.notes,
      required this.state,
      required this.created,
      required this.completed,
      this.targetProtein,
      this.targetCarbs,
      this.targetFats,
      required this.isTemporal});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['parentPlanId'] = Variable<int>(parentPlanId);
    map['title'] = Variable<String>(title);
    map['notes'] = Variable<String>(notes);
    {
      map['state'] =
          Variable<String>($MealPlansTable.$converterstate.toSql(state));
    }
    {
      map['created'] =
          Variable<String>($MealPlansTable.$convertercreated.toSql(created));
    }
    {
      map['completed'] = Variable<String>(
          $MealPlansTable.$convertercompleted.toSql(completed));
    }
    if (!nullToAbsent || targetProtein != null) {
      map['target_protein'] = Variable<double>(targetProtein);
    }
    if (!nullToAbsent || targetCarbs != null) {
      map['target_carbs'] = Variable<double>(targetCarbs);
    }
    if (!nullToAbsent || targetFats != null) {
      map['target_fats'] = Variable<double>(targetFats);
    }
    map['isTemporal'] = Variable<bool>(isTemporal);
    return map;
  }

  MealPlansCompanion toCompanion(bool nullToAbsent) {
    return MealPlansCompanion(
      id: Value(id),
      parentPlanId: Value(parentPlanId),
      title: Value(title),
      notes: Value(notes),
      state: Value(state),
      created: Value(created),
      completed: Value(completed),
      targetProtein: targetProtein == null && nullToAbsent
          ? const Value.absent()
          : Value(targetProtein),
      targetCarbs: targetCarbs == null && nullToAbsent
          ? const Value.absent()
          : Value(targetCarbs),
      targetFats: targetFats == null && nullToAbsent
          ? const Value.absent()
          : Value(targetFats),
      isTemporal: Value(isTemporal),
    );
  }

  factory MealPlan.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MealPlan(
      id: serializer.fromJson<int>(json['id']),
      parentPlanId: serializer.fromJson<int>(json['parentPlanId']),
      title: serializer.fromJson<String>(json['title']),
      notes: serializer.fromJson<String>(json['notes']),
      state: serializer.fromJson<MealPlanState>(json['state']),
      created: serializer.fromJson<DateTime>(json['created']),
      completed: serializer.fromJson<DateTime>(json['completed']),
      targetProtein: serializer.fromJson<double?>(json['targetProtein']),
      targetCarbs: serializer.fromJson<double?>(json['targetCarbs']),
      targetFats: serializer.fromJson<double?>(json['targetFats']),
      isTemporal: serializer.fromJson<bool>(json['isTemporal']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'parentPlanId': serializer.toJson<int>(parentPlanId),
      'title': serializer.toJson<String>(title),
      'notes': serializer.toJson<String>(notes),
      'state': serializer.toJson<MealPlanState>(state),
      'created': serializer.toJson<DateTime>(created),
      'completed': serializer.toJson<DateTime>(completed),
      'targetProtein': serializer.toJson<double?>(targetProtein),
      'targetCarbs': serializer.toJson<double?>(targetCarbs),
      'targetFats': serializer.toJson<double?>(targetFats),
      'isTemporal': serializer.toJson<bool>(isTemporal),
    };
  }

  MealPlan copyWith(
          {int? id,
          int? parentPlanId,
          String? title,
          String? notes,
          MealPlanState? state,
          DateTime? created,
          DateTime? completed,
          Value<double?> targetProtein = const Value.absent(),
          Value<double?> targetCarbs = const Value.absent(),
          Value<double?> targetFats = const Value.absent(),
          bool? isTemporal}) =>
      MealPlan(
        id: id ?? this.id,
        parentPlanId: parentPlanId ?? this.parentPlanId,
        title: title ?? this.title,
        notes: notes ?? this.notes,
        state: state ?? this.state,
        created: created ?? this.created,
        completed: completed ?? this.completed,
        targetProtein:
            targetProtein.present ? targetProtein.value : this.targetProtein,
        targetCarbs: targetCarbs.present ? targetCarbs.value : this.targetCarbs,
        targetFats: targetFats.present ? targetFats.value : this.targetFats,
        isTemporal: isTemporal ?? this.isTemporal,
      );
  @override
  String toString() {
    return (StringBuffer('MealPlan(')
          ..write('id: $id, ')
          ..write('parentPlanId: $parentPlanId, ')
          ..write('title: $title, ')
          ..write('notes: $notes, ')
          ..write('state: $state, ')
          ..write('created: $created, ')
          ..write('completed: $completed, ')
          ..write('targetProtein: $targetProtein, ')
          ..write('targetCarbs: $targetCarbs, ')
          ..write('targetFats: $targetFats, ')
          ..write('isTemporal: $isTemporal')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, parentPlanId, title, notes, state,
      created, completed, targetProtein, targetCarbs, targetFats, isTemporal);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MealPlan &&
          other.id == this.id &&
          other.parentPlanId == this.parentPlanId &&
          other.title == this.title &&
          other.notes == this.notes &&
          other.state == this.state &&
          other.created == this.created &&
          other.completed == this.completed &&
          other.targetProtein == this.targetProtein &&
          other.targetCarbs == this.targetCarbs &&
          other.targetFats == this.targetFats &&
          other.isTemporal == this.isTemporal);
}

class MealPlansCompanion extends UpdateCompanion<MealPlan> {
  final Value<int> id;
  final Value<int> parentPlanId;
  final Value<String> title;
  final Value<String> notes;
  final Value<MealPlanState> state;
  final Value<DateTime> created;
  final Value<DateTime> completed;
  final Value<double?> targetProtein;
  final Value<double?> targetCarbs;
  final Value<double?> targetFats;
  final Value<bool> isTemporal;
  const MealPlansCompanion({
    this.id = const Value.absent(),
    this.parentPlanId = const Value.absent(),
    this.title = const Value.absent(),
    this.notes = const Value.absent(),
    this.state = const Value.absent(),
    this.created = const Value.absent(),
    this.completed = const Value.absent(),
    this.targetProtein = const Value.absent(),
    this.targetCarbs = const Value.absent(),
    this.targetFats = const Value.absent(),
    this.isTemporal = const Value.absent(),
  });
  MealPlansCompanion.insert({
    this.id = const Value.absent(),
    required int parentPlanId,
    required String title,
    required String notes,
    required MealPlanState state,
    required DateTime created,
    required DateTime completed,
    this.targetProtein = const Value.absent(),
    this.targetCarbs = const Value.absent(),
    this.targetFats = const Value.absent(),
    this.isTemporal = const Value.absent(),
  })  : parentPlanId = Value(parentPlanId),
        title = Value(title),
        notes = Value(notes),
        state = Value(state),
        created = Value(created),
        completed = Value(completed);
  static Insertable<MealPlan> custom({
    Expression<int>? id,
    Expression<int>? parentPlanId,
    Expression<String>? title,
    Expression<String>? notes,
    Expression<String>? state,
    Expression<String>? created,
    Expression<String>? completed,
    Expression<double>? targetProtein,
    Expression<double>? targetCarbs,
    Expression<double>? targetFats,
    Expression<bool>? isTemporal,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (parentPlanId != null) 'parentPlanId': parentPlanId,
      if (title != null) 'title': title,
      if (notes != null) 'notes': notes,
      if (state != null) 'state': state,
      if (created != null) 'created': created,
      if (completed != null) 'completed': completed,
      if (targetProtein != null) 'target_protein': targetProtein,
      if (targetCarbs != null) 'target_carbs': targetCarbs,
      if (targetFats != null) 'target_fats': targetFats,
      if (isTemporal != null) 'isTemporal': isTemporal,
    });
  }

  MealPlansCompanion copyWith(
      {Value<int>? id,
      Value<int>? parentPlanId,
      Value<String>? title,
      Value<String>? notes,
      Value<MealPlanState>? state,
      Value<DateTime>? created,
      Value<DateTime>? completed,
      Value<double?>? targetProtein,
      Value<double?>? targetCarbs,
      Value<double?>? targetFats,
      Value<bool>? isTemporal}) {
    return MealPlansCompanion(
      id: id ?? this.id,
      parentPlanId: parentPlanId ?? this.parentPlanId,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      state: state ?? this.state,
      created: created ?? this.created,
      completed: completed ?? this.completed,
      targetProtein: targetProtein ?? this.targetProtein,
      targetCarbs: targetCarbs ?? this.targetCarbs,
      targetFats: targetFats ?? this.targetFats,
      isTemporal: isTemporal ?? this.isTemporal,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (parentPlanId.present) {
      map['parentPlanId'] = Variable<int>(parentPlanId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (state.present) {
      map['state'] =
          Variable<String>($MealPlansTable.$converterstate.toSql(state.value));
    }
    if (created.present) {
      map['created'] = Variable<String>(
          $MealPlansTable.$convertercreated.toSql(created.value));
    }
    if (completed.present) {
      map['completed'] = Variable<String>(
          $MealPlansTable.$convertercompleted.toSql(completed.value));
    }
    if (targetProtein.present) {
      map['target_protein'] = Variable<double>(targetProtein.value);
    }
    if (targetCarbs.present) {
      map['target_carbs'] = Variable<double>(targetCarbs.value);
    }
    if (targetFats.present) {
      map['target_fats'] = Variable<double>(targetFats.value);
    }
    if (isTemporal.present) {
      map['isTemporal'] = Variable<bool>(isTemporal.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MealPlansCompanion(')
          ..write('id: $id, ')
          ..write('parentPlanId: $parentPlanId, ')
          ..write('title: $title, ')
          ..write('notes: $notes, ')
          ..write('state: $state, ')
          ..write('created: $created, ')
          ..write('completed: $completed, ')
          ..write('targetProtein: $targetProtein, ')
          ..write('targetCarbs: $targetCarbs, ')
          ..write('targetFats: $targetFats, ')
          ..write('isTemporal: $isTemporal')
          ..write(')'))
        .toString();
  }
}

class $MealsTable extends Meals with TableInfo<$MealsTable, Meal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MealsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _mealPlanIdMeta =
      const VerificationMeta('mealPlanId');
  @override
  late final GeneratedColumn<int> mealPlanId = GeneratedColumn<int>(
      'mealPlanId', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _timeMeta = const VerificationMeta('time');
  @override
  late final GeneratedColumnWithTypeConverter<LocalTime, String> time =
      GeneratedColumn<String>('time', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<LocalTime>($MealsTable.$convertertime);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _positionMeta =
      const VerificationMeta('position');
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
      'position', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, mealPlanId, name, time, notes, position];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'meals';
  @override
  VerificationContext validateIntegrity(Insertable<Meal> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('mealPlanId')) {
      context.handle(
          _mealPlanIdMeta,
          mealPlanId.isAcceptableOrUnknown(
              data['mealPlanId']!, _mealPlanIdMeta));
    } else if (isInserting) {
      context.missing(_mealPlanIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    context.handle(_timeMeta, const VerificationResult.success());
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    } else if (isInserting) {
      context.missing(_notesMeta);
    }
    if (data.containsKey('position')) {
      context.handle(_positionMeta,
          position.isAcceptableOrUnknown(data['position']!, _positionMeta));
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Meal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Meal(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      mealPlanId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}mealPlanId'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      time: $MealsTable.$convertertime.fromSql(attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}time'])!),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes'])!,
      position: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}position'])!,
    );
  }

  @override
  $MealsTable createAlias(String alias) {
    return $MealsTable(attachedDatabase, alias);
  }

  static TypeConverter<LocalTime, String> $convertertime =
      const LocalTimeConverter();
}

class Meal extends DataClass implements Insertable<Meal> {
  final int id;
  final int mealPlanId;
  final String name;
  final LocalTime time;
  final String notes;
  final int position;
  const Meal(
      {required this.id,
      required this.mealPlanId,
      required this.name,
      required this.time,
      required this.notes,
      required this.position});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['mealPlanId'] = Variable<int>(mealPlanId);
    map['name'] = Variable<String>(name);
    {
      map['time'] = Variable<String>($MealsTable.$convertertime.toSql(time));
    }
    map['notes'] = Variable<String>(notes);
    map['position'] = Variable<int>(position);
    return map;
  }

  MealsCompanion toCompanion(bool nullToAbsent) {
    return MealsCompanion(
      id: Value(id),
      mealPlanId: Value(mealPlanId),
      name: Value(name),
      time: Value(time),
      notes: Value(notes),
      position: Value(position),
    );
  }

  factory Meal.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Meal(
      id: serializer.fromJson<int>(json['id']),
      mealPlanId: serializer.fromJson<int>(json['mealPlanId']),
      name: serializer.fromJson<String>(json['name']),
      time: serializer.fromJson<LocalTime>(json['time']),
      notes: serializer.fromJson<String>(json['notes']),
      position: serializer.fromJson<int>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'mealPlanId': serializer.toJson<int>(mealPlanId),
      'name': serializer.toJson<String>(name),
      'time': serializer.toJson<LocalTime>(time),
      'notes': serializer.toJson<String>(notes),
      'position': serializer.toJson<int>(position),
    };
  }

  Meal copyWith(
          {int? id,
          int? mealPlanId,
          String? name,
          LocalTime? time,
          String? notes,
          int? position}) =>
      Meal(
        id: id ?? this.id,
        mealPlanId: mealPlanId ?? this.mealPlanId,
        name: name ?? this.name,
        time: time ?? this.time,
        notes: notes ?? this.notes,
        position: position ?? this.position,
      );
  @override
  String toString() {
    return (StringBuffer('Meal(')
          ..write('id: $id, ')
          ..write('mealPlanId: $mealPlanId, ')
          ..write('name: $name, ')
          ..write('time: $time, ')
          ..write('notes: $notes, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, mealPlanId, name, time, notes, position);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Meal &&
          other.id == this.id &&
          other.mealPlanId == this.mealPlanId &&
          other.name == this.name &&
          other.time == this.time &&
          other.notes == this.notes &&
          other.position == this.position);
}

class MealsCompanion extends UpdateCompanion<Meal> {
  final Value<int> id;
  final Value<int> mealPlanId;
  final Value<String> name;
  final Value<LocalTime> time;
  final Value<String> notes;
  final Value<int> position;
  const MealsCompanion({
    this.id = const Value.absent(),
    this.mealPlanId = const Value.absent(),
    this.name = const Value.absent(),
    this.time = const Value.absent(),
    this.notes = const Value.absent(),
    this.position = const Value.absent(),
  });
  MealsCompanion.insert({
    this.id = const Value.absent(),
    required int mealPlanId,
    required String name,
    required LocalTime time,
    required String notes,
    required int position,
  })  : mealPlanId = Value(mealPlanId),
        name = Value(name),
        time = Value(time),
        notes = Value(notes),
        position = Value(position);
  static Insertable<Meal> custom({
    Expression<int>? id,
    Expression<int>? mealPlanId,
    Expression<String>? name,
    Expression<String>? time,
    Expression<String>? notes,
    Expression<int>? position,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (mealPlanId != null) 'mealPlanId': mealPlanId,
      if (name != null) 'name': name,
      if (time != null) 'time': time,
      if (notes != null) 'notes': notes,
      if (position != null) 'position': position,
    });
  }

  MealsCompanion copyWith(
      {Value<int>? id,
      Value<int>? mealPlanId,
      Value<String>? name,
      Value<LocalTime>? time,
      Value<String>? notes,
      Value<int>? position}) {
    return MealsCompanion(
      id: id ?? this.id,
      mealPlanId: mealPlanId ?? this.mealPlanId,
      name: name ?? this.name,
      time: time ?? this.time,
      notes: notes ?? this.notes,
      position: position ?? this.position,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (mealPlanId.present) {
      map['mealPlanId'] = Variable<int>(mealPlanId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (time.present) {
      map['time'] =
          Variable<String>($MealsTable.$convertertime.toSql(time.value));
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MealsCompanion(')
          ..write('id: $id, ')
          ..write('mealPlanId: $mealPlanId, ')
          ..write('name: $name, ')
          ..write('time: $time, ')
          ..write('notes: $notes, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }
}

class $MealItemsTable extends MealItems
    with TableInfo<$MealItemsTable, MealItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MealItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _mealIdMeta = const VerificationMeta('mealId');
  @override
  late final GeneratedColumn<int> mealId = GeneratedColumn<int>(
      'mealId', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumnWithTypeConverter<MealItemType, String> type =
      GeneratedColumn<String>('type', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<MealItemType>($MealItemsTable.$convertertype);
  static const VerificationMeta _targetIdMeta =
      const VerificationMeta('targetId');
  @override
  late final GeneratedColumn<int> targetId = GeneratedColumn<int>(
      'targetId', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _amountUnitMeta =
      const VerificationMeta('amountUnit');
  @override
  late final GeneratedColumnWithTypeConverter<AmountUnit, String> amountUnit =
      GeneratedColumn<String>('amountUnit', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              defaultValue: const Constant('GRAMS'))
          .withConverter<AmountUnit>($MealItemsTable.$converteramountUnit);
  static const VerificationMeta _consumedMeta =
      const VerificationMeta('consumed');
  @override
  late final GeneratedColumn<bool> consumed = GeneratedColumn<bool>(
      'consumed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("consumed" IN (0, 1))'));
  static const VerificationMeta _positionMeta =
      const VerificationMeta('position');
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
      'position', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, mealId, type, targetId, amount, amountUnit, consumed, position];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'meal_items';
  @override
  VerificationContext validateIntegrity(Insertable<MealItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('mealId')) {
      context.handle(_mealIdMeta,
          mealId.isAcceptableOrUnknown(data['mealId']!, _mealIdMeta));
    } else if (isInserting) {
      context.missing(_mealIdMeta);
    }
    context.handle(_typeMeta, const VerificationResult.success());
    if (data.containsKey('targetId')) {
      context.handle(_targetIdMeta,
          targetId.isAcceptableOrUnknown(data['targetId']!, _targetIdMeta));
    } else if (isInserting) {
      context.missing(_targetIdMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    context.handle(_amountUnitMeta, const VerificationResult.success());
    if (data.containsKey('consumed')) {
      context.handle(_consumedMeta,
          consumed.isAcceptableOrUnknown(data['consumed']!, _consumedMeta));
    } else if (isInserting) {
      context.missing(_consumedMeta);
    }
    if (data.containsKey('position')) {
      context.handle(_positionMeta,
          position.isAcceptableOrUnknown(data['position']!, _positionMeta));
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MealItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MealItem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      mealId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}mealId'])!,
      type: $MealItemsTable.$convertertype.fromSql(attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!),
      targetId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}targetId'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      amountUnit: $MealItemsTable.$converteramountUnit.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}amountUnit'])!),
      consumed: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}consumed'])!,
      position: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}position'])!,
    );
  }

  @override
  $MealItemsTable createAlias(String alias) {
    return $MealItemsTable(attachedDatabase, alias);
  }

  static TypeConverter<MealItemType, String> $convertertype =
      const EnumNameConverter(MealItemType.values);
  static TypeConverter<AmountUnit, String> $converteramountUnit =
      const EnumNameConverter(AmountUnit.values);
}

class MealItem extends DataClass implements Insertable<MealItem> {
  final int id;
  final int mealId;
  final MealItemType type;
  final int targetId;
  final double amount;

  /// Unit for amount: GRAMS (default) or UNITS (e.g. 1 banana).
  final AmountUnit amountUnit;
  final bool consumed;
  final int position;
  const MealItem(
      {required this.id,
      required this.mealId,
      required this.type,
      required this.targetId,
      required this.amount,
      required this.amountUnit,
      required this.consumed,
      required this.position});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['mealId'] = Variable<int>(mealId);
    {
      map['type'] =
          Variable<String>($MealItemsTable.$convertertype.toSql(type));
    }
    map['targetId'] = Variable<int>(targetId);
    map['amount'] = Variable<double>(amount);
    {
      map['amountUnit'] = Variable<String>(
          $MealItemsTable.$converteramountUnit.toSql(amountUnit));
    }
    map['consumed'] = Variable<bool>(consumed);
    map['position'] = Variable<int>(position);
    return map;
  }

  MealItemsCompanion toCompanion(bool nullToAbsent) {
    return MealItemsCompanion(
      id: Value(id),
      mealId: Value(mealId),
      type: Value(type),
      targetId: Value(targetId),
      amount: Value(amount),
      amountUnit: Value(amountUnit),
      consumed: Value(consumed),
      position: Value(position),
    );
  }

  factory MealItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MealItem(
      id: serializer.fromJson<int>(json['id']),
      mealId: serializer.fromJson<int>(json['mealId']),
      type: serializer.fromJson<MealItemType>(json['type']),
      targetId: serializer.fromJson<int>(json['targetId']),
      amount: serializer.fromJson<double>(json['amount']),
      amountUnit: serializer.fromJson<AmountUnit>(json['amountUnit']),
      consumed: serializer.fromJson<bool>(json['consumed']),
      position: serializer.fromJson<int>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'mealId': serializer.toJson<int>(mealId),
      'type': serializer.toJson<MealItemType>(type),
      'targetId': serializer.toJson<int>(targetId),
      'amount': serializer.toJson<double>(amount),
      'amountUnit': serializer.toJson<AmountUnit>(amountUnit),
      'consumed': serializer.toJson<bool>(consumed),
      'position': serializer.toJson<int>(position),
    };
  }

  MealItem copyWith(
          {int? id,
          int? mealId,
          MealItemType? type,
          int? targetId,
          double? amount,
          AmountUnit? amountUnit,
          bool? consumed,
          int? position}) =>
      MealItem(
        id: id ?? this.id,
        mealId: mealId ?? this.mealId,
        type: type ?? this.type,
        targetId: targetId ?? this.targetId,
        amount: amount ?? this.amount,
        amountUnit: amountUnit ?? this.amountUnit,
        consumed: consumed ?? this.consumed,
        position: position ?? this.position,
      );
  @override
  String toString() {
    return (StringBuffer('MealItem(')
          ..write('id: $id, ')
          ..write('mealId: $mealId, ')
          ..write('type: $type, ')
          ..write('targetId: $targetId, ')
          ..write('amount: $amount, ')
          ..write('amountUnit: $amountUnit, ')
          ..write('consumed: $consumed, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, mealId, type, targetId, amount, amountUnit, consumed, position);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MealItem &&
          other.id == this.id &&
          other.mealId == this.mealId &&
          other.type == this.type &&
          other.targetId == this.targetId &&
          other.amount == this.amount &&
          other.amountUnit == this.amountUnit &&
          other.consumed == this.consumed &&
          other.position == this.position);
}

class MealItemsCompanion extends UpdateCompanion<MealItem> {
  final Value<int> id;
  final Value<int> mealId;
  final Value<MealItemType> type;
  final Value<int> targetId;
  final Value<double> amount;
  final Value<AmountUnit> amountUnit;
  final Value<bool> consumed;
  final Value<int> position;
  const MealItemsCompanion({
    this.id = const Value.absent(),
    this.mealId = const Value.absent(),
    this.type = const Value.absent(),
    this.targetId = const Value.absent(),
    this.amount = const Value.absent(),
    this.amountUnit = const Value.absent(),
    this.consumed = const Value.absent(),
    this.position = const Value.absent(),
  });
  MealItemsCompanion.insert({
    this.id = const Value.absent(),
    required int mealId,
    required MealItemType type,
    required int targetId,
    required double amount,
    this.amountUnit = const Value.absent(),
    required bool consumed,
    required int position,
  })  : mealId = Value(mealId),
        type = Value(type),
        targetId = Value(targetId),
        amount = Value(amount),
        consumed = Value(consumed),
        position = Value(position);
  static Insertable<MealItem> custom({
    Expression<int>? id,
    Expression<int>? mealId,
    Expression<String>? type,
    Expression<int>? targetId,
    Expression<double>? amount,
    Expression<String>? amountUnit,
    Expression<bool>? consumed,
    Expression<int>? position,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (mealId != null) 'mealId': mealId,
      if (type != null) 'type': type,
      if (targetId != null) 'targetId': targetId,
      if (amount != null) 'amount': amount,
      if (amountUnit != null) 'amountUnit': amountUnit,
      if (consumed != null) 'consumed': consumed,
      if (position != null) 'position': position,
    });
  }

  MealItemsCompanion copyWith(
      {Value<int>? id,
      Value<int>? mealId,
      Value<MealItemType>? type,
      Value<int>? targetId,
      Value<double>? amount,
      Value<AmountUnit>? amountUnit,
      Value<bool>? consumed,
      Value<int>? position}) {
    return MealItemsCompanion(
      id: id ?? this.id,
      mealId: mealId ?? this.mealId,
      type: type ?? this.type,
      targetId: targetId ?? this.targetId,
      amount: amount ?? this.amount,
      amountUnit: amountUnit ?? this.amountUnit,
      consumed: consumed ?? this.consumed,
      position: position ?? this.position,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (mealId.present) {
      map['mealId'] = Variable<int>(mealId.value);
    }
    if (type.present) {
      map['type'] =
          Variable<String>($MealItemsTable.$convertertype.toSql(type.value));
    }
    if (targetId.present) {
      map['targetId'] = Variable<int>(targetId.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (amountUnit.present) {
      map['amountUnit'] = Variable<String>(
          $MealItemsTable.$converteramountUnit.toSql(amountUnit.value));
    }
    if (consumed.present) {
      map['consumed'] = Variable<bool>(consumed.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MealItemsCompanion(')
          ..write('id: $id, ')
          ..write('mealId: $mealId, ')
          ..write('type: $type, ')
          ..write('targetId: $targetId, ')
          ..write('amount: $amount, ')
          ..write('amountUnit: $amountUnit, ')
          ..write('consumed: $consumed, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  _$AppDatabaseManager get managers => _$AppDatabaseManager(this);
  late final $WorkoutsTable workouts = $WorkoutsTable(this);
  late final $ExerciseDataTable exerciseData = $ExerciseDataTable(this);
  late final $ExercisesTable exercises = $ExercisesTable(this);
  late final $SetsTable sets = $SetsTable(this);
  late final $BodyMeasurementsTable bodyMeasurements =
      $BodyMeasurementsTable(this);
  late final $AdvancedBodyMeasurementsTable advancedBodyMeasurements =
      $AdvancedBodyMeasurementsTable(this);
  late final $ActivityMeasurementsTable activityMeasurements =
      $ActivityMeasurementsTable(this);
  late final $SleepMeasurementsTable sleepMeasurements =
      $SleepMeasurementsTable(this);
  late final $AdvancedSleepMeasurementsTable advancedSleepMeasurements =
      $AdvancedSleepMeasurementsTable(this);
  late final $ProductsTable products = $ProductsTable(this);
  late final $RecipesTable recipes = $RecipesTable(this);
  late final $RecipeIngredientsTable recipeIngredients =
      $RecipeIngredientsTable(this);
  late final $MealPlansTable mealPlans = $MealPlansTable(this);
  late final $MealsTable meals = $MealsTable(this);
  late final $MealItemsTable mealItems = $MealItemsTable(this);
  late final Index indexExercisesWorkoutId = Index('index_exercises_workoutId',
      'CREATE INDEX index_exercises_workoutId ON exercises (workoutId)');
  late final Index indexExercisesWorkoutIdPosition = Index(
      'index_exercises_workoutId_position',
      'CREATE INDEX index_exercises_workoutId_position ON exercises (workoutId, position)');
  late final Index indexExercisesExerciseDataId = Index(
      'index_exercises_exerciseDataId',
      'CREATE INDEX index_exercises_exerciseDataId ON exercises (exerciseDataId)');
  late final Index indexSetsExerciseId = Index('index_sets_exerciseId',
      'CREATE INDEX index_sets_exerciseId ON sets (exerciseId)');
  late final Index indexRecipeIngredientsRecipeId = Index(
      'index_recipe_ingredients_recipeId',
      'CREATE INDEX index_recipe_ingredients_recipeId ON recipe_ingredients (recipeId)');
  late final Index indexRecipeIngredientsProductId = Index(
      'index_recipe_ingredients_productId',
      'CREATE INDEX index_recipe_ingredients_productId ON recipe_ingredients (productId)');
  late final Index indexMealsMealPlanId = Index('index_meals_mealPlanId',
      'CREATE INDEX index_meals_mealPlanId ON meals (mealPlanId)');
  late final Index indexMealsMealPlanIdPosition = Index(
      'index_meals_mealPlanId_position',
      'CREATE INDEX index_meals_mealPlanId_position ON meals (mealPlanId, position)');
  late final Index indexMealItemsMealId = Index('index_meal_items_mealId',
      'CREATE INDEX index_meal_items_mealId ON meal_items (mealId)');
  late final Index indexMealItemsMealIdPosition = Index(
      'index_meal_items_mealId_position',
      'CREATE INDEX index_meal_items_mealId_position ON meal_items (mealId, position)');
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        workouts,
        exerciseData,
        exercises,
        sets,
        bodyMeasurements,
        advancedBodyMeasurements,
        activityMeasurements,
        sleepMeasurements,
        advancedSleepMeasurements,
        products,
        recipes,
        recipeIngredients,
        mealPlans,
        meals,
        mealItems,
        indexExercisesWorkoutId,
        indexExercisesWorkoutIdPosition,
        indexExercisesExerciseDataId,
        indexSetsExerciseId,
        indexRecipeIngredientsRecipeId,
        indexRecipeIngredientsProductId,
        indexMealsMealPlanId,
        indexMealsMealPlanIdPosition,
        indexMealItemsMealId,
        indexMealItemsMealIdPosition
      ];
}

typedef $$WorkoutsTableInsertCompanionBuilder = WorkoutsCompanion Function({
  Value<int> id,
  required int routineId,
  required String notes,
  required String title,
  required WorkoutState state,
  required int timeElapsed,
  required DateTime created,
  required DateTime completed,
});
typedef $$WorkoutsTableUpdateCompanionBuilder = WorkoutsCompanion Function({
  Value<int> id,
  Value<int> routineId,
  Value<String> notes,
  Value<String> title,
  Value<WorkoutState> state,
  Value<int> timeElapsed,
  Value<DateTime> created,
  Value<DateTime> completed,
});

class $$WorkoutsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $WorkoutsTable,
    Workout,
    $$WorkoutsTableFilterComposer,
    $$WorkoutsTableOrderingComposer,
    $$WorkoutsTableProcessedTableManager,
    $$WorkoutsTableInsertCompanionBuilder,
    $$WorkoutsTableUpdateCompanionBuilder> {
  $$WorkoutsTableTableManager(_$AppDatabase db, $WorkoutsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$WorkoutsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$WorkoutsTableOrderingComposer(ComposerState(db, table)),
          getChildManagerBuilder: (p) =>
              $$WorkoutsTableProcessedTableManager(p),
          getUpdateCompanionBuilder: ({
            Value<int> id = const Value.absent(),
            Value<int> routineId = const Value.absent(),
            Value<String> notes = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<WorkoutState> state = const Value.absent(),
            Value<int> timeElapsed = const Value.absent(),
            Value<DateTime> created = const Value.absent(),
            Value<DateTime> completed = const Value.absent(),
          }) =>
              WorkoutsCompanion(
            id: id,
            routineId: routineId,
            notes: notes,
            title: title,
            state: state,
            timeElapsed: timeElapsed,
            created: created,
            completed: completed,
          ),
          getInsertCompanionBuilder: ({
            Value<int> id = const Value.absent(),
            required int routineId,
            required String notes,
            required String title,
            required WorkoutState state,
            required int timeElapsed,
            required DateTime created,
            required DateTime completed,
          }) =>
              WorkoutsCompanion.insert(
            id: id,
            routineId: routineId,
            notes: notes,
            title: title,
            state: state,
            timeElapsed: timeElapsed,
            created: created,
            completed: completed,
          ),
        ));
}

class $$WorkoutsTableProcessedTableManager extends ProcessedTableManager<
    _$AppDatabase,
    $WorkoutsTable,
    Workout,
    $$WorkoutsTableFilterComposer,
    $$WorkoutsTableOrderingComposer,
    $$WorkoutsTableProcessedTableManager,
    $$WorkoutsTableInsertCompanionBuilder,
    $$WorkoutsTableUpdateCompanionBuilder> {
  $$WorkoutsTableProcessedTableManager(super.$state);
}

class $$WorkoutsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $WorkoutsTable> {
  $$WorkoutsTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get routineId => $state.composableBuilder(
      column: $state.table.routineId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get notes => $state.composableBuilder(
      column: $state.table.notes,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get title => $state.composableBuilder(
      column: $state.table.title,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnWithTypeConverterFilters<WorkoutState, WorkoutState, String>
      get state => $state.composableBuilder(
          column: $state.table.state,
          builder: (column, joinBuilders) => ColumnWithTypeConverterFilters(
              column,
              joinBuilders: joinBuilders));

  ColumnFilters<int> get timeElapsed => $state.composableBuilder(
      column: $state.table.timeElapsed,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get created =>
      $state.composableBuilder(
          column: $state.table.created,
          builder: (column, joinBuilders) => ColumnWithTypeConverterFilters(
              column,
              joinBuilders: joinBuilders));

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get completed =>
      $state.composableBuilder(
          column: $state.table.completed,
          builder: (column, joinBuilders) => ColumnWithTypeConverterFilters(
              column,
              joinBuilders: joinBuilders));
}

class $$WorkoutsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $WorkoutsTable> {
  $$WorkoutsTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get routineId => $state.composableBuilder(
      column: $state.table.routineId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get notes => $state.composableBuilder(
      column: $state.table.notes,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get title => $state.composableBuilder(
      column: $state.table.title,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get state => $state.composableBuilder(
      column: $state.table.state,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get timeElapsed => $state.composableBuilder(
      column: $state.table.timeElapsed,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get created => $state.composableBuilder(
      column: $state.table.created,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get completed => $state.composableBuilder(
      column: $state.table.completed,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$ExerciseDataTableInsertCompanionBuilder = ExerciseDataCompanion
    Function({
  required String id,
  required String name,
  Value<Force?> force,
  required Level level,
  Value<Mechanic?> mechanic,
  Value<Equipment?> equipment,
  required List<Muscle> primaryMuscles,
  required List<Muscle> secondaryMuscles,
  required List<String> instructions,
  required Category category,
  required List<String> images,
  required bool isCustomExercise,
  Value<int> rowid,
});
typedef $$ExerciseDataTableUpdateCompanionBuilder = ExerciseDataCompanion
    Function({
  Value<String> id,
  Value<String> name,
  Value<Force?> force,
  Value<Level> level,
  Value<Mechanic?> mechanic,
  Value<Equipment?> equipment,
  Value<List<Muscle>> primaryMuscles,
  Value<List<Muscle>> secondaryMuscles,
  Value<List<String>> instructions,
  Value<Category> category,
  Value<List<String>> images,
  Value<bool> isCustomExercise,
  Value<int> rowid,
});

class $$ExerciseDataTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ExerciseDataTable,
    ExerciseDataDC,
    $$ExerciseDataTableFilterComposer,
    $$ExerciseDataTableOrderingComposer,
    $$ExerciseDataTableProcessedTableManager,
    $$ExerciseDataTableInsertCompanionBuilder,
    $$ExerciseDataTableUpdateCompanionBuilder> {
  $$ExerciseDataTableTableManager(_$AppDatabase db, $ExerciseDataTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$ExerciseDataTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$ExerciseDataTableOrderingComposer(ComposerState(db, table)),
          getChildManagerBuilder: (p) =>
              $$ExerciseDataTableProcessedTableManager(p),
          getUpdateCompanionBuilder: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<Force?> force = const Value.absent(),
            Value<Level> level = const Value.absent(),
            Value<Mechanic?> mechanic = const Value.absent(),
            Value<Equipment?> equipment = const Value.absent(),
            Value<List<Muscle>> primaryMuscles = const Value.absent(),
            Value<List<Muscle>> secondaryMuscles = const Value.absent(),
            Value<List<String>> instructions = const Value.absent(),
            Value<Category> category = const Value.absent(),
            Value<List<String>> images = const Value.absent(),
            Value<bool> isCustomExercise = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ExerciseDataCompanion(
            id: id,
            name: name,
            force: force,
            level: level,
            mechanic: mechanic,
            equipment: equipment,
            primaryMuscles: primaryMuscles,
            secondaryMuscles: secondaryMuscles,
            instructions: instructions,
            category: category,
            images: images,
            isCustomExercise: isCustomExercise,
            rowid: rowid,
          ),
          getInsertCompanionBuilder: ({
            required String id,
            required String name,
            Value<Force?> force = const Value.absent(),
            required Level level,
            Value<Mechanic?> mechanic = const Value.absent(),
            Value<Equipment?> equipment = const Value.absent(),
            required List<Muscle> primaryMuscles,
            required List<Muscle> secondaryMuscles,
            required List<String> instructions,
            required Category category,
            required List<String> images,
            required bool isCustomExercise,
            Value<int> rowid = const Value.absent(),
          }) =>
              ExerciseDataCompanion.insert(
            id: id,
            name: name,
            force: force,
            level: level,
            mechanic: mechanic,
            equipment: equipment,
            primaryMuscles: primaryMuscles,
            secondaryMuscles: secondaryMuscles,
            instructions: instructions,
            category: category,
            images: images,
            isCustomExercise: isCustomExercise,
            rowid: rowid,
          ),
        ));
}

class $$ExerciseDataTableProcessedTableManager extends ProcessedTableManager<
    _$AppDatabase,
    $ExerciseDataTable,
    ExerciseDataDC,
    $$ExerciseDataTableFilterComposer,
    $$ExerciseDataTableOrderingComposer,
    $$ExerciseDataTableProcessedTableManager,
    $$ExerciseDataTableInsertCompanionBuilder,
    $$ExerciseDataTableUpdateCompanionBuilder> {
  $$ExerciseDataTableProcessedTableManager(super.$state);
}

class $$ExerciseDataTableFilterComposer
    extends FilterComposer<_$AppDatabase, $ExerciseDataTable> {
  $$ExerciseDataTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnWithTypeConverterFilters<Force?, Force, String> get force =>
      $state.composableBuilder(
          column: $state.table.force,
          builder: (column, joinBuilders) => ColumnWithTypeConverterFilters(
              column,
              joinBuilders: joinBuilders));

  ColumnWithTypeConverterFilters<Level, Level, String> get level =>
      $state.composableBuilder(
          column: $state.table.level,
          builder: (column, joinBuilders) => ColumnWithTypeConverterFilters(
              column,
              joinBuilders: joinBuilders));

  ColumnWithTypeConverterFilters<Mechanic?, Mechanic, String> get mechanic =>
      $state.composableBuilder(
          column: $state.table.mechanic,
          builder: (column, joinBuilders) => ColumnWithTypeConverterFilters(
              column,
              joinBuilders: joinBuilders));

  ColumnWithTypeConverterFilters<Equipment?, Equipment, String> get equipment =>
      $state.composableBuilder(
          column: $state.table.equipment,
          builder: (column, joinBuilders) => ColumnWithTypeConverterFilters(
              column,
              joinBuilders: joinBuilders));

  ColumnWithTypeConverterFilters<List<Muscle>, List<Muscle>, String>
      get primaryMuscles => $state.composableBuilder(
          column: $state.table.primaryMuscles,
          builder: (column, joinBuilders) => ColumnWithTypeConverterFilters(
              column,
              joinBuilders: joinBuilders));

  ColumnWithTypeConverterFilters<List<Muscle>, List<Muscle>, String>
      get secondaryMuscles => $state.composableBuilder(
          column: $state.table.secondaryMuscles,
          builder: (column, joinBuilders) => ColumnWithTypeConverterFilters(
              column,
              joinBuilders: joinBuilders));

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
      get instructions => $state.composableBuilder(
          column: $state.table.instructions,
          builder: (column, joinBuilders) => ColumnWithTypeConverterFilters(
              column,
              joinBuilders: joinBuilders));

  ColumnWithTypeConverterFilters<Category, Category, String> get category =>
      $state.composableBuilder(
          column: $state.table.category,
          builder: (column, joinBuilders) => ColumnWithTypeConverterFilters(
              column,
              joinBuilders: joinBuilders));

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
      get images => $state.composableBuilder(
          column: $state.table.images,
          builder: (column, joinBuilders) => ColumnWithTypeConverterFilters(
              column,
              joinBuilders: joinBuilders));

  ColumnFilters<bool> get isCustomExercise => $state.composableBuilder(
      column: $state.table.isCustomExercise,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$ExerciseDataTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $ExerciseDataTable> {
  $$ExerciseDataTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get force => $state.composableBuilder(
      column: $state.table.force,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get level => $state.composableBuilder(
      column: $state.table.level,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get mechanic => $state.composableBuilder(
      column: $state.table.mechanic,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get equipment => $state.composableBuilder(
      column: $state.table.equipment,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get primaryMuscles => $state.composableBuilder(
      column: $state.table.primaryMuscles,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get secondaryMuscles => $state.composableBuilder(
      column: $state.table.secondaryMuscles,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get instructions => $state.composableBuilder(
      column: $state.table.instructions,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get category => $state.composableBuilder(
      column: $state.table.category,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get images => $state.composableBuilder(
      column: $state.table.images,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get isCustomExercise => $state.composableBuilder(
      column: $state.table.isCustomExercise,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$ExercisesTableInsertCompanionBuilder = ExercisesCompanion Function({
  Value<int> id,
  required String exerciseDataId,
  required String notes,
  required SetMode setMode,
  required int restTime,
  Value<int> position,
  Value<int?> supersetId,
  required int workoutId,
});
typedef $$ExercisesTableUpdateCompanionBuilder = ExercisesCompanion Function({
  Value<int> id,
  Value<String> exerciseDataId,
  Value<String> notes,
  Value<SetMode> setMode,
  Value<int> restTime,
  Value<int> position,
  Value<int?> supersetId,
  Value<int> workoutId,
});

class $$ExercisesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ExercisesTable,
    Exercise,
    $$ExercisesTableFilterComposer,
    $$ExercisesTableOrderingComposer,
    $$ExercisesTableProcessedTableManager,
    $$ExercisesTableInsertCompanionBuilder,
    $$ExercisesTableUpdateCompanionBuilder> {
  $$ExercisesTableTableManager(_$AppDatabase db, $ExercisesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$ExercisesTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$ExercisesTableOrderingComposer(ComposerState(db, table)),
          getChildManagerBuilder: (p) =>
              $$ExercisesTableProcessedTableManager(p),
          getUpdateCompanionBuilder: ({
            Value<int> id = const Value.absent(),
            Value<String> exerciseDataId = const Value.absent(),
            Value<String> notes = const Value.absent(),
            Value<SetMode> setMode = const Value.absent(),
            Value<int> restTime = const Value.absent(),
            Value<int> position = const Value.absent(),
            Value<int?> supersetId = const Value.absent(),
            Value<int> workoutId = const Value.absent(),
          }) =>
              ExercisesCompanion(
            id: id,
            exerciseDataId: exerciseDataId,
            notes: notes,
            setMode: setMode,
            restTime: restTime,
            position: position,
            supersetId: supersetId,
            workoutId: workoutId,
          ),
          getInsertCompanionBuilder: ({
            Value<int> id = const Value.absent(),
            required String exerciseDataId,
            required String notes,
            required SetMode setMode,
            required int restTime,
            Value<int> position = const Value.absent(),
            Value<int?> supersetId = const Value.absent(),
            required int workoutId,
          }) =>
              ExercisesCompanion.insert(
            id: id,
            exerciseDataId: exerciseDataId,
            notes: notes,
            setMode: setMode,
            restTime: restTime,
            position: position,
            supersetId: supersetId,
            workoutId: workoutId,
          ),
        ));
}

class $$ExercisesTableProcessedTableManager extends ProcessedTableManager<
    _$AppDatabase,
    $ExercisesTable,
    Exercise,
    $$ExercisesTableFilterComposer,
    $$ExercisesTableOrderingComposer,
    $$ExercisesTableProcessedTableManager,
    $$ExercisesTableInsertCompanionBuilder,
    $$ExercisesTableUpdateCompanionBuilder> {
  $$ExercisesTableProcessedTableManager(super.$state);
}

class $$ExercisesTableFilterComposer
    extends FilterComposer<_$AppDatabase, $ExercisesTable> {
  $$ExercisesTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get exerciseDataId => $state.composableBuilder(
      column: $state.table.exerciseDataId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get notes => $state.composableBuilder(
      column: $state.table.notes,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnWithTypeConverterFilters<SetMode, SetMode, String> get setMode =>
      $state.composableBuilder(
          column: $state.table.setMode,
          builder: (column, joinBuilders) => ColumnWithTypeConverterFilters(
              column,
              joinBuilders: joinBuilders));

  ColumnFilters<int> get restTime => $state.composableBuilder(
      column: $state.table.restTime,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get position => $state.composableBuilder(
      column: $state.table.position,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get supersetId => $state.composableBuilder(
      column: $state.table.supersetId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get workoutId => $state.composableBuilder(
      column: $state.table.workoutId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$ExercisesTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $ExercisesTable> {
  $$ExercisesTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get exerciseDataId => $state.composableBuilder(
      column: $state.table.exerciseDataId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get notes => $state.composableBuilder(
      column: $state.table.notes,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get setMode => $state.composableBuilder(
      column: $state.table.setMode,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get restTime => $state.composableBuilder(
      column: $state.table.restTime,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get position => $state.composableBuilder(
      column: $state.table.position,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get supersetId => $state.composableBuilder(
      column: $state.table.supersetId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get workoutId => $state.composableBuilder(
      column: $state.table.workoutId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$SetsTableInsertCompanionBuilder = SetsCompanion Function({
  Value<int> id,
  required double load,
  required int reps,
  required int elapsedTime,
  required bool completed,
  Value<double?> rpe,
  Value<int?> rir,
  Value<int?> intensityScale1,
  required int exerciseId,
});
typedef $$SetsTableUpdateCompanionBuilder = SetsCompanion Function({
  Value<int> id,
  Value<double> load,
  Value<int> reps,
  Value<int> elapsedTime,
  Value<bool> completed,
  Value<double?> rpe,
  Value<int?> rir,
  Value<int?> intensityScale1,
  Value<int> exerciseId,
});

class $$SetsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SetsTable,
    WorkoutSet,
    $$SetsTableFilterComposer,
    $$SetsTableOrderingComposer,
    $$SetsTableProcessedTableManager,
    $$SetsTableInsertCompanionBuilder,
    $$SetsTableUpdateCompanionBuilder> {
  $$SetsTableTableManager(_$AppDatabase db, $SetsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$SetsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$SetsTableOrderingComposer(ComposerState(db, table)),
          getChildManagerBuilder: (p) => $$SetsTableProcessedTableManager(p),
          getUpdateCompanionBuilder: ({
            Value<int> id = const Value.absent(),
            Value<double> load = const Value.absent(),
            Value<int> reps = const Value.absent(),
            Value<int> elapsedTime = const Value.absent(),
            Value<bool> completed = const Value.absent(),
            Value<double?> rpe = const Value.absent(),
            Value<int?> rir = const Value.absent(),
            Value<int?> intensityScale1 = const Value.absent(),
            Value<int> exerciseId = const Value.absent(),
          }) =>
              SetsCompanion(
            id: id,
            load: load,
            reps: reps,
            elapsedTime: elapsedTime,
            completed: completed,
            rpe: rpe,
            rir: rir,
            intensityScale1: intensityScale1,
            exerciseId: exerciseId,
          ),
          getInsertCompanionBuilder: ({
            Value<int> id = const Value.absent(),
            required double load,
            required int reps,
            required int elapsedTime,
            required bool completed,
            Value<double?> rpe = const Value.absent(),
            Value<int?> rir = const Value.absent(),
            Value<int?> intensityScale1 = const Value.absent(),
            required int exerciseId,
          }) =>
              SetsCompanion.insert(
            id: id,
            load: load,
            reps: reps,
            elapsedTime: elapsedTime,
            completed: completed,
            rpe: rpe,
            rir: rir,
            intensityScale1: intensityScale1,
            exerciseId: exerciseId,
          ),
        ));
}

class $$SetsTableProcessedTableManager extends ProcessedTableManager<
    _$AppDatabase,
    $SetsTable,
    WorkoutSet,
    $$SetsTableFilterComposer,
    $$SetsTableOrderingComposer,
    $$SetsTableProcessedTableManager,
    $$SetsTableInsertCompanionBuilder,
    $$SetsTableUpdateCompanionBuilder> {
  $$SetsTableProcessedTableManager(super.$state);
}

class $$SetsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $SetsTable> {
  $$SetsTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get load => $state.composableBuilder(
      column: $state.table.load,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get reps => $state.composableBuilder(
      column: $state.table.reps,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get elapsedTime => $state.composableBuilder(
      column: $state.table.elapsedTime,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get completed => $state.composableBuilder(
      column: $state.table.completed,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get rpe => $state.composableBuilder(
      column: $state.table.rpe,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get rir => $state.composableBuilder(
      column: $state.table.rir,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get intensityScale1 => $state.composableBuilder(
      column: $state.table.intensityScale1,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get exerciseId => $state.composableBuilder(
      column: $state.table.exerciseId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$SetsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $SetsTable> {
  $$SetsTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get load => $state.composableBuilder(
      column: $state.table.load,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get reps => $state.composableBuilder(
      column: $state.table.reps,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get elapsedTime => $state.composableBuilder(
      column: $state.table.elapsedTime,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get completed => $state.composableBuilder(
      column: $state.table.completed,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get rpe => $state.composableBuilder(
      column: $state.table.rpe,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get rir => $state.composableBuilder(
      column: $state.table.rir,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get intensityScale1 => $state.composableBuilder(
      column: $state.table.intensityScale1,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get exerciseId => $state.composableBuilder(
      column: $state.table.exerciseId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$BodyMeasurementsTableInsertCompanionBuilder
    = BodyMeasurementsCompanion Function({
  Value<int> id,
  required double bodyWeight,
  required DateTime date,
});
typedef $$BodyMeasurementsTableUpdateCompanionBuilder
    = BodyMeasurementsCompanion Function({
  Value<int> id,
  Value<double> bodyWeight,
  Value<DateTime> date,
});

class $$BodyMeasurementsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BodyMeasurementsTable,
    BodyMeasurement,
    $$BodyMeasurementsTableFilterComposer,
    $$BodyMeasurementsTableOrderingComposer,
    $$BodyMeasurementsTableProcessedTableManager,
    $$BodyMeasurementsTableInsertCompanionBuilder,
    $$BodyMeasurementsTableUpdateCompanionBuilder> {
  $$BodyMeasurementsTableTableManager(
      _$AppDatabase db, $BodyMeasurementsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$BodyMeasurementsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$BodyMeasurementsTableOrderingComposer(ComposerState(db, table)),
          getChildManagerBuilder: (p) =>
              $$BodyMeasurementsTableProcessedTableManager(p),
          getUpdateCompanionBuilder: ({
            Value<int> id = const Value.absent(),
            Value<double> bodyWeight = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
          }) =>
              BodyMeasurementsCompanion(
            id: id,
            bodyWeight: bodyWeight,
            date: date,
          ),
          getInsertCompanionBuilder: ({
            Value<int> id = const Value.absent(),
            required double bodyWeight,
            required DateTime date,
          }) =>
              BodyMeasurementsCompanion.insert(
            id: id,
            bodyWeight: bodyWeight,
            date: date,
          ),
        ));
}

class $$BodyMeasurementsTableProcessedTableManager
    extends ProcessedTableManager<
        _$AppDatabase,
        $BodyMeasurementsTable,
        BodyMeasurement,
        $$BodyMeasurementsTableFilterComposer,
        $$BodyMeasurementsTableOrderingComposer,
        $$BodyMeasurementsTableProcessedTableManager,
        $$BodyMeasurementsTableInsertCompanionBuilder,
        $$BodyMeasurementsTableUpdateCompanionBuilder> {
  $$BodyMeasurementsTableProcessedTableManager(super.$state);
}

class $$BodyMeasurementsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $BodyMeasurementsTable> {
  $$BodyMeasurementsTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get bodyWeight => $state.composableBuilder(
      column: $state.table.bodyWeight,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get date =>
      $state.composableBuilder(
          column: $state.table.date,
          builder: (column, joinBuilders) => ColumnWithTypeConverterFilters(
              column,
              joinBuilders: joinBuilders));
}

class $$BodyMeasurementsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $BodyMeasurementsTable> {
  $$BodyMeasurementsTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get bodyWeight => $state.composableBuilder(
      column: $state.table.bodyWeight,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get date => $state.composableBuilder(
      column: $state.table.date,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$AdvancedBodyMeasurementsTableInsertCompanionBuilder
    = AdvancedBodyMeasurementsCompanion Function({
  Value<int> id,
  Value<int?> bodyFatPercentage,
  Value<int?> muscleMassPercentage,
  Value<double?> neckCircumference,
  Value<double?> chestCircumference,
  Value<double?> waistCircumference,
  Value<double?> hipCircumference,
  Value<double?> bicepLeft,
  Value<double?> bicepRight,
  Value<double?> thighLeft,
  Value<double?> thighRight,
  Value<double?> calfLeft,
  Value<double?> calfRight,
  required DateTime date,
});
typedef $$AdvancedBodyMeasurementsTableUpdateCompanionBuilder
    = AdvancedBodyMeasurementsCompanion Function({
  Value<int> id,
  Value<int?> bodyFatPercentage,
  Value<int?> muscleMassPercentage,
  Value<double?> neckCircumference,
  Value<double?> chestCircumference,
  Value<double?> waistCircumference,
  Value<double?> hipCircumference,
  Value<double?> bicepLeft,
  Value<double?> bicepRight,
  Value<double?> thighLeft,
  Value<double?> thighRight,
  Value<double?> calfLeft,
  Value<double?> calfRight,
  Value<DateTime> date,
});

class $$AdvancedBodyMeasurementsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AdvancedBodyMeasurementsTable,
    AdvancedBodyMeasurement,
    $$AdvancedBodyMeasurementsTableFilterComposer,
    $$AdvancedBodyMeasurementsTableOrderingComposer,
    $$AdvancedBodyMeasurementsTableProcessedTableManager,
    $$AdvancedBodyMeasurementsTableInsertCompanionBuilder,
    $$AdvancedBodyMeasurementsTableUpdateCompanionBuilder> {
  $$AdvancedBodyMeasurementsTableTableManager(
      _$AppDatabase db, $AdvancedBodyMeasurementsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer: $$AdvancedBodyMeasurementsTableFilterComposer(
              ComposerState(db, table)),
          orderingComposer: $$AdvancedBodyMeasurementsTableOrderingComposer(
              ComposerState(db, table)),
          getChildManagerBuilder: (p) =>
              $$AdvancedBodyMeasurementsTableProcessedTableManager(p),
          getUpdateCompanionBuilder: ({
            Value<int> id = const Value.absent(),
            Value<int?> bodyFatPercentage = const Value.absent(),
            Value<int?> muscleMassPercentage = const Value.absent(),
            Value<double?> neckCircumference = const Value.absent(),
            Value<double?> chestCircumference = const Value.absent(),
            Value<double?> waistCircumference = const Value.absent(),
            Value<double?> hipCircumference = const Value.absent(),
            Value<double?> bicepLeft = const Value.absent(),
            Value<double?> bicepRight = const Value.absent(),
            Value<double?> thighLeft = const Value.absent(),
            Value<double?> thighRight = const Value.absent(),
            Value<double?> calfLeft = const Value.absent(),
            Value<double?> calfRight = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
          }) =>
              AdvancedBodyMeasurementsCompanion(
            id: id,
            bodyFatPercentage: bodyFatPercentage,
            muscleMassPercentage: muscleMassPercentage,
            neckCircumference: neckCircumference,
            chestCircumference: chestCircumference,
            waistCircumference: waistCircumference,
            hipCircumference: hipCircumference,
            bicepLeft: bicepLeft,
            bicepRight: bicepRight,
            thighLeft: thighLeft,
            thighRight: thighRight,
            calfLeft: calfLeft,
            calfRight: calfRight,
            date: date,
          ),
          getInsertCompanionBuilder: ({
            Value<int> id = const Value.absent(),
            Value<int?> bodyFatPercentage = const Value.absent(),
            Value<int?> muscleMassPercentage = const Value.absent(),
            Value<double?> neckCircumference = const Value.absent(),
            Value<double?> chestCircumference = const Value.absent(),
            Value<double?> waistCircumference = const Value.absent(),
            Value<double?> hipCircumference = const Value.absent(),
            Value<double?> bicepLeft = const Value.absent(),
            Value<double?> bicepRight = const Value.absent(),
            Value<double?> thighLeft = const Value.absent(),
            Value<double?> thighRight = const Value.absent(),
            Value<double?> calfLeft = const Value.absent(),
            Value<double?> calfRight = const Value.absent(),
            required DateTime date,
          }) =>
              AdvancedBodyMeasurementsCompanion.insert(
            id: id,
            bodyFatPercentage: bodyFatPercentage,
            muscleMassPercentage: muscleMassPercentage,
            neckCircumference: neckCircumference,
            chestCircumference: chestCircumference,
            waistCircumference: waistCircumference,
            hipCircumference: hipCircumference,
            bicepLeft: bicepLeft,
            bicepRight: bicepRight,
            thighLeft: thighLeft,
            thighRight: thighRight,
            calfLeft: calfLeft,
            calfRight: calfRight,
            date: date,
          ),
        ));
}

class $$AdvancedBodyMeasurementsTableProcessedTableManager
    extends ProcessedTableManager<
        _$AppDatabase,
        $AdvancedBodyMeasurementsTable,
        AdvancedBodyMeasurement,
        $$AdvancedBodyMeasurementsTableFilterComposer,
        $$AdvancedBodyMeasurementsTableOrderingComposer,
        $$AdvancedBodyMeasurementsTableProcessedTableManager,
        $$AdvancedBodyMeasurementsTableInsertCompanionBuilder,
        $$AdvancedBodyMeasurementsTableUpdateCompanionBuilder> {
  $$AdvancedBodyMeasurementsTableProcessedTableManager(super.$state);
}

class $$AdvancedBodyMeasurementsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $AdvancedBodyMeasurementsTable> {
  $$AdvancedBodyMeasurementsTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get bodyFatPercentage => $state.composableBuilder(
      column: $state.table.bodyFatPercentage,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get muscleMassPercentage => $state.composableBuilder(
      column: $state.table.muscleMassPercentage,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get neckCircumference => $state.composableBuilder(
      column: $state.table.neckCircumference,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get chestCircumference => $state.composableBuilder(
      column: $state.table.chestCircumference,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get waistCircumference => $state.composableBuilder(
      column: $state.table.waistCircumference,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get hipCircumference => $state.composableBuilder(
      column: $state.table.hipCircumference,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get bicepLeft => $state.composableBuilder(
      column: $state.table.bicepLeft,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get bicepRight => $state.composableBuilder(
      column: $state.table.bicepRight,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get thighLeft => $state.composableBuilder(
      column: $state.table.thighLeft,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get thighRight => $state.composableBuilder(
      column: $state.table.thighRight,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get calfLeft => $state.composableBuilder(
      column: $state.table.calfLeft,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get calfRight => $state.composableBuilder(
      column: $state.table.calfRight,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get date =>
      $state.composableBuilder(
          column: $state.table.date,
          builder: (column, joinBuilders) => ColumnWithTypeConverterFilters(
              column,
              joinBuilders: joinBuilders));
}

class $$AdvancedBodyMeasurementsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $AdvancedBodyMeasurementsTable> {
  $$AdvancedBodyMeasurementsTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get bodyFatPercentage => $state.composableBuilder(
      column: $state.table.bodyFatPercentage,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get muscleMassPercentage => $state.composableBuilder(
      column: $state.table.muscleMassPercentage,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get neckCircumference => $state.composableBuilder(
      column: $state.table.neckCircumference,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get chestCircumference => $state.composableBuilder(
      column: $state.table.chestCircumference,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get waistCircumference => $state.composableBuilder(
      column: $state.table.waistCircumference,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get hipCircumference => $state.composableBuilder(
      column: $state.table.hipCircumference,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get bicepLeft => $state.composableBuilder(
      column: $state.table.bicepLeft,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get bicepRight => $state.composableBuilder(
      column: $state.table.bicepRight,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get thighLeft => $state.composableBuilder(
      column: $state.table.thighLeft,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get thighRight => $state.composableBuilder(
      column: $state.table.thighRight,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get calfLeft => $state.composableBuilder(
      column: $state.table.calfLeft,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get calfRight => $state.composableBuilder(
      column: $state.table.calfRight,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get date => $state.composableBuilder(
      column: $state.table.date,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$ActivityMeasurementsTableInsertCompanionBuilder
    = ActivityMeasurementsCompanion Function({
  Value<int> id,
  Value<int?> wakingRHR,
  Value<int?> wakingHRV,
  Value<int?> dailySteps,
  Value<double?> activeEnergyBurned,
  Value<double?> vo2Max,
  required DateTime date,
});
typedef $$ActivityMeasurementsTableUpdateCompanionBuilder
    = ActivityMeasurementsCompanion Function({
  Value<int> id,
  Value<int?> wakingRHR,
  Value<int?> wakingHRV,
  Value<int?> dailySteps,
  Value<double?> activeEnergyBurned,
  Value<double?> vo2Max,
  Value<DateTime> date,
});

class $$ActivityMeasurementsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ActivityMeasurementsTable,
    ActivityMeasurement,
    $$ActivityMeasurementsTableFilterComposer,
    $$ActivityMeasurementsTableOrderingComposer,
    $$ActivityMeasurementsTableProcessedTableManager,
    $$ActivityMeasurementsTableInsertCompanionBuilder,
    $$ActivityMeasurementsTableUpdateCompanionBuilder> {
  $$ActivityMeasurementsTableTableManager(
      _$AppDatabase db, $ActivityMeasurementsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer: $$ActivityMeasurementsTableFilterComposer(
              ComposerState(db, table)),
          orderingComposer: $$ActivityMeasurementsTableOrderingComposer(
              ComposerState(db, table)),
          getChildManagerBuilder: (p) =>
              $$ActivityMeasurementsTableProcessedTableManager(p),
          getUpdateCompanionBuilder: ({
            Value<int> id = const Value.absent(),
            Value<int?> wakingRHR = const Value.absent(),
            Value<int?> wakingHRV = const Value.absent(),
            Value<int?> dailySteps = const Value.absent(),
            Value<double?> activeEnergyBurned = const Value.absent(),
            Value<double?> vo2Max = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
          }) =>
              ActivityMeasurementsCompanion(
            id: id,
            wakingRHR: wakingRHR,
            wakingHRV: wakingHRV,
            dailySteps: dailySteps,
            activeEnergyBurned: activeEnergyBurned,
            vo2Max: vo2Max,
            date: date,
          ),
          getInsertCompanionBuilder: ({
            Value<int> id = const Value.absent(),
            Value<int?> wakingRHR = const Value.absent(),
            Value<int?> wakingHRV = const Value.absent(),
            Value<int?> dailySteps = const Value.absent(),
            Value<double?> activeEnergyBurned = const Value.absent(),
            Value<double?> vo2Max = const Value.absent(),
            required DateTime date,
          }) =>
              ActivityMeasurementsCompanion.insert(
            id: id,
            wakingRHR: wakingRHR,
            wakingHRV: wakingHRV,
            dailySteps: dailySteps,
            activeEnergyBurned: activeEnergyBurned,
            vo2Max: vo2Max,
            date: date,
          ),
        ));
}

class $$ActivityMeasurementsTableProcessedTableManager
    extends ProcessedTableManager<
        _$AppDatabase,
        $ActivityMeasurementsTable,
        ActivityMeasurement,
        $$ActivityMeasurementsTableFilterComposer,
        $$ActivityMeasurementsTableOrderingComposer,
        $$ActivityMeasurementsTableProcessedTableManager,
        $$ActivityMeasurementsTableInsertCompanionBuilder,
        $$ActivityMeasurementsTableUpdateCompanionBuilder> {
  $$ActivityMeasurementsTableProcessedTableManager(super.$state);
}

class $$ActivityMeasurementsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $ActivityMeasurementsTable> {
  $$ActivityMeasurementsTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get wakingRHR => $state.composableBuilder(
      column: $state.table.wakingRHR,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get wakingHRV => $state.composableBuilder(
      column: $state.table.wakingHRV,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get dailySteps => $state.composableBuilder(
      column: $state.table.dailySteps,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get activeEnergyBurned => $state.composableBuilder(
      column: $state.table.activeEnergyBurned,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get vo2Max => $state.composableBuilder(
      column: $state.table.vo2Max,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get date =>
      $state.composableBuilder(
          column: $state.table.date,
          builder: (column, joinBuilders) => ColumnWithTypeConverterFilters(
              column,
              joinBuilders: joinBuilders));
}

class $$ActivityMeasurementsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $ActivityMeasurementsTable> {
  $$ActivityMeasurementsTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get wakingRHR => $state.composableBuilder(
      column: $state.table.wakingRHR,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get wakingHRV => $state.composableBuilder(
      column: $state.table.wakingHRV,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get dailySteps => $state.composableBuilder(
      column: $state.table.dailySteps,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get activeEnergyBurned => $state.composableBuilder(
      column: $state.table.activeEnergyBurned,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get vo2Max => $state.composableBuilder(
      column: $state.table.vo2Max,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get date => $state.composableBuilder(
      column: $state.table.date,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$SleepMeasurementsTableInsertCompanionBuilder
    = SleepMeasurementsCompanion Function({
  Value<int> id,
  Value<double?> sleepDuration,
  Value<double?> deepSleepDuration,
  Value<double?> lightSleepDuration,
  Value<double?> remSleepDuration,
  Value<int?> sleepingRHR,
  Value<int?> sleepingHRV,
  required DateTime date,
});
typedef $$SleepMeasurementsTableUpdateCompanionBuilder
    = SleepMeasurementsCompanion Function({
  Value<int> id,
  Value<double?> sleepDuration,
  Value<double?> deepSleepDuration,
  Value<double?> lightSleepDuration,
  Value<double?> remSleepDuration,
  Value<int?> sleepingRHR,
  Value<int?> sleepingHRV,
  Value<DateTime> date,
});

class $$SleepMeasurementsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SleepMeasurementsTable,
    SleepMeasurement,
    $$SleepMeasurementsTableFilterComposer,
    $$SleepMeasurementsTableOrderingComposer,
    $$SleepMeasurementsTableProcessedTableManager,
    $$SleepMeasurementsTableInsertCompanionBuilder,
    $$SleepMeasurementsTableUpdateCompanionBuilder> {
  $$SleepMeasurementsTableTableManager(
      _$AppDatabase db, $SleepMeasurementsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$SleepMeasurementsTableFilterComposer(ComposerState(db, table)),
          orderingComposer: $$SleepMeasurementsTableOrderingComposer(
              ComposerState(db, table)),
          getChildManagerBuilder: (p) =>
              $$SleepMeasurementsTableProcessedTableManager(p),
          getUpdateCompanionBuilder: ({
            Value<int> id = const Value.absent(),
            Value<double?> sleepDuration = const Value.absent(),
            Value<double?> deepSleepDuration = const Value.absent(),
            Value<double?> lightSleepDuration = const Value.absent(),
            Value<double?> remSleepDuration = const Value.absent(),
            Value<int?> sleepingRHR = const Value.absent(),
            Value<int?> sleepingHRV = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
          }) =>
              SleepMeasurementsCompanion(
            id: id,
            sleepDuration: sleepDuration,
            deepSleepDuration: deepSleepDuration,
            lightSleepDuration: lightSleepDuration,
            remSleepDuration: remSleepDuration,
            sleepingRHR: sleepingRHR,
            sleepingHRV: sleepingHRV,
            date: date,
          ),
          getInsertCompanionBuilder: ({
            Value<int> id = const Value.absent(),
            Value<double?> sleepDuration = const Value.absent(),
            Value<double?> deepSleepDuration = const Value.absent(),
            Value<double?> lightSleepDuration = const Value.absent(),
            Value<double?> remSleepDuration = const Value.absent(),
            Value<int?> sleepingRHR = const Value.absent(),
            Value<int?> sleepingHRV = const Value.absent(),
            required DateTime date,
          }) =>
              SleepMeasurementsCompanion.insert(
            id: id,
            sleepDuration: sleepDuration,
            deepSleepDuration: deepSleepDuration,
            lightSleepDuration: lightSleepDuration,
            remSleepDuration: remSleepDuration,
            sleepingRHR: sleepingRHR,
            sleepingHRV: sleepingHRV,
            date: date,
          ),
        ));
}

class $$SleepMeasurementsTableProcessedTableManager
    extends ProcessedTableManager<
        _$AppDatabase,
        $SleepMeasurementsTable,
        SleepMeasurement,
        $$SleepMeasurementsTableFilterComposer,
        $$SleepMeasurementsTableOrderingComposer,
        $$SleepMeasurementsTableProcessedTableManager,
        $$SleepMeasurementsTableInsertCompanionBuilder,
        $$SleepMeasurementsTableUpdateCompanionBuilder> {
  $$SleepMeasurementsTableProcessedTableManager(super.$state);
}

class $$SleepMeasurementsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $SleepMeasurementsTable> {
  $$SleepMeasurementsTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get sleepDuration => $state.composableBuilder(
      column: $state.table.sleepDuration,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get deepSleepDuration => $state.composableBuilder(
      column: $state.table.deepSleepDuration,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get lightSleepDuration => $state.composableBuilder(
      column: $state.table.lightSleepDuration,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get remSleepDuration => $state.composableBuilder(
      column: $state.table.remSleepDuration,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get sleepingRHR => $state.composableBuilder(
      column: $state.table.sleepingRHR,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get sleepingHRV => $state.composableBuilder(
      column: $state.table.sleepingHRV,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get date =>
      $state.composableBuilder(
          column: $state.table.date,
          builder: (column, joinBuilders) => ColumnWithTypeConverterFilters(
              column,
              joinBuilders: joinBuilders));
}

class $$SleepMeasurementsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $SleepMeasurementsTable> {
  $$SleepMeasurementsTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get sleepDuration => $state.composableBuilder(
      column: $state.table.sleepDuration,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get deepSleepDuration => $state.composableBuilder(
      column: $state.table.deepSleepDuration,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get lightSleepDuration => $state.composableBuilder(
      column: $state.table.lightSleepDuration,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get remSleepDuration => $state.composableBuilder(
      column: $state.table.remSleepDuration,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get sleepingRHR => $state.composableBuilder(
      column: $state.table.sleepingRHR,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get sleepingHRV => $state.composableBuilder(
      column: $state.table.sleepingHRV,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get date => $state.composableBuilder(
      column: $state.table.date,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$AdvancedSleepMeasurementsTableInsertCompanionBuilder
    = AdvancedSleepMeasurementsCompanion Function({
  Value<int> id,
  Value<double?> timeInBed,
  Value<double?> totalAwakeTime,
  Value<int?> numberOfAwakenings,
  Value<double?> longestAwakePeriod,
  Value<double?> sleepLatency,
  Value<double?> deepSleepLatency,
  Value<double?> remSleepLatency,
  Value<double?> deepSleepFragmentation,
  Value<double?> lightSleepFragmentation,
  Value<double?> remSleepFragmentation,
  required DateTime date,
  Value<String?> notes,
});
typedef $$AdvancedSleepMeasurementsTableUpdateCompanionBuilder
    = AdvancedSleepMeasurementsCompanion Function({
  Value<int> id,
  Value<double?> timeInBed,
  Value<double?> totalAwakeTime,
  Value<int?> numberOfAwakenings,
  Value<double?> longestAwakePeriod,
  Value<double?> sleepLatency,
  Value<double?> deepSleepLatency,
  Value<double?> remSleepLatency,
  Value<double?> deepSleepFragmentation,
  Value<double?> lightSleepFragmentation,
  Value<double?> remSleepFragmentation,
  Value<DateTime> date,
  Value<String?> notes,
});

class $$AdvancedSleepMeasurementsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AdvancedSleepMeasurementsTable,
    AdvancedSleepMeasurement,
    $$AdvancedSleepMeasurementsTableFilterComposer,
    $$AdvancedSleepMeasurementsTableOrderingComposer,
    $$AdvancedSleepMeasurementsTableProcessedTableManager,
    $$AdvancedSleepMeasurementsTableInsertCompanionBuilder,
    $$AdvancedSleepMeasurementsTableUpdateCompanionBuilder> {
  $$AdvancedSleepMeasurementsTableTableManager(
      _$AppDatabase db, $AdvancedSleepMeasurementsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer: $$AdvancedSleepMeasurementsTableFilterComposer(
              ComposerState(db, table)),
          orderingComposer: $$AdvancedSleepMeasurementsTableOrderingComposer(
              ComposerState(db, table)),
          getChildManagerBuilder: (p) =>
              $$AdvancedSleepMeasurementsTableProcessedTableManager(p),
          getUpdateCompanionBuilder: ({
            Value<int> id = const Value.absent(),
            Value<double?> timeInBed = const Value.absent(),
            Value<double?> totalAwakeTime = const Value.absent(),
            Value<int?> numberOfAwakenings = const Value.absent(),
            Value<double?> longestAwakePeriod = const Value.absent(),
            Value<double?> sleepLatency = const Value.absent(),
            Value<double?> deepSleepLatency = const Value.absent(),
            Value<double?> remSleepLatency = const Value.absent(),
            Value<double?> deepSleepFragmentation = const Value.absent(),
            Value<double?> lightSleepFragmentation = const Value.absent(),
            Value<double?> remSleepFragmentation = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<String?> notes = const Value.absent(),
          }) =>
              AdvancedSleepMeasurementsCompanion(
            id: id,
            timeInBed: timeInBed,
            totalAwakeTime: totalAwakeTime,
            numberOfAwakenings: numberOfAwakenings,
            longestAwakePeriod: longestAwakePeriod,
            sleepLatency: sleepLatency,
            deepSleepLatency: deepSleepLatency,
            remSleepLatency: remSleepLatency,
            deepSleepFragmentation: deepSleepFragmentation,
            lightSleepFragmentation: lightSleepFragmentation,
            remSleepFragmentation: remSleepFragmentation,
            date: date,
            notes: notes,
          ),
          getInsertCompanionBuilder: ({
            Value<int> id = const Value.absent(),
            Value<double?> timeInBed = const Value.absent(),
            Value<double?> totalAwakeTime = const Value.absent(),
            Value<int?> numberOfAwakenings = const Value.absent(),
            Value<double?> longestAwakePeriod = const Value.absent(),
            Value<double?> sleepLatency = const Value.absent(),
            Value<double?> deepSleepLatency = const Value.absent(),
            Value<double?> remSleepLatency = const Value.absent(),
            Value<double?> deepSleepFragmentation = const Value.absent(),
            Value<double?> lightSleepFragmentation = const Value.absent(),
            Value<double?> remSleepFragmentation = const Value.absent(),
            required DateTime date,
            Value<String?> notes = const Value.absent(),
          }) =>
              AdvancedSleepMeasurementsCompanion.insert(
            id: id,
            timeInBed: timeInBed,
            totalAwakeTime: totalAwakeTime,
            numberOfAwakenings: numberOfAwakenings,
            longestAwakePeriod: longestAwakePeriod,
            sleepLatency: sleepLatency,
            deepSleepLatency: deepSleepLatency,
            remSleepLatency: remSleepLatency,
            deepSleepFragmentation: deepSleepFragmentation,
            lightSleepFragmentation: lightSleepFragmentation,
            remSleepFragmentation: remSleepFragmentation,
            date: date,
            notes: notes,
          ),
        ));
}

class $$AdvancedSleepMeasurementsTableProcessedTableManager
    extends ProcessedTableManager<
        _$AppDatabase,
        $AdvancedSleepMeasurementsTable,
        AdvancedSleepMeasurement,
        $$AdvancedSleepMeasurementsTableFilterComposer,
        $$AdvancedSleepMeasurementsTableOrderingComposer,
        $$AdvancedSleepMeasurementsTableProcessedTableManager,
        $$AdvancedSleepMeasurementsTableInsertCompanionBuilder,
        $$AdvancedSleepMeasurementsTableUpdateCompanionBuilder> {
  $$AdvancedSleepMeasurementsTableProcessedTableManager(super.$state);
}

class $$AdvancedSleepMeasurementsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $AdvancedSleepMeasurementsTable> {
  $$AdvancedSleepMeasurementsTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get timeInBed => $state.composableBuilder(
      column: $state.table.timeInBed,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get totalAwakeTime => $state.composableBuilder(
      column: $state.table.totalAwakeTime,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get numberOfAwakenings => $state.composableBuilder(
      column: $state.table.numberOfAwakenings,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get longestAwakePeriod => $state.composableBuilder(
      column: $state.table.longestAwakePeriod,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get sleepLatency => $state.composableBuilder(
      column: $state.table.sleepLatency,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get deepSleepLatency => $state.composableBuilder(
      column: $state.table.deepSleepLatency,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get remSleepLatency => $state.composableBuilder(
      column: $state.table.remSleepLatency,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get deepSleepFragmentation => $state.composableBuilder(
      column: $state.table.deepSleepFragmentation,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get lightSleepFragmentation => $state.composableBuilder(
      column: $state.table.lightSleepFragmentation,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get remSleepFragmentation => $state.composableBuilder(
      column: $state.table.remSleepFragmentation,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get date =>
      $state.composableBuilder(
          column: $state.table.date,
          builder: (column, joinBuilders) => ColumnWithTypeConverterFilters(
              column,
              joinBuilders: joinBuilders));

  ColumnFilters<String> get notes => $state.composableBuilder(
      column: $state.table.notes,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$AdvancedSleepMeasurementsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $AdvancedSleepMeasurementsTable> {
  $$AdvancedSleepMeasurementsTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get timeInBed => $state.composableBuilder(
      column: $state.table.timeInBed,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get totalAwakeTime => $state.composableBuilder(
      column: $state.table.totalAwakeTime,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get numberOfAwakenings => $state.composableBuilder(
      column: $state.table.numberOfAwakenings,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get longestAwakePeriod => $state.composableBuilder(
      column: $state.table.longestAwakePeriod,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get sleepLatency => $state.composableBuilder(
      column: $state.table.sleepLatency,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get deepSleepLatency => $state.composableBuilder(
      column: $state.table.deepSleepLatency,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get remSleepLatency => $state.composableBuilder(
      column: $state.table.remSleepLatency,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get deepSleepFragmentation =>
      $state.composableBuilder(
          column: $state.table.deepSleepFragmentation,
          builder: (column, joinBuilders) =>
              ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get lightSleepFragmentation =>
      $state.composableBuilder(
          column: $state.table.lightSleepFragmentation,
          builder: (column, joinBuilders) =>
              ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get remSleepFragmentation => $state.composableBuilder(
      column: $state.table.remSleepFragmentation,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get date => $state.composableBuilder(
      column: $state.table.date,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get notes => $state.composableBuilder(
      column: $state.table.notes,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$ProductsTableInsertCompanionBuilder = ProductsCompanion Function({
  Value<int> id,
  required String name,
  required double weight,
  Value<int?> mlToGFactor,
  Value<int?> unitWeight,
  Value<String?> defaultUnits,
  Value<double?> edibleQtyPerUnit,
  Value<double?> kcal,
  required double proteins,
  Value<double?> carbsByDifference,
  Value<double?> carbsAvailable,
  Value<double?> dietaryFiber,
  required double fats,
  required bool isSupplement,
  Value<bool> isPortable,
});
typedef $$ProductsTableUpdateCompanionBuilder = ProductsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<double> weight,
  Value<int?> mlToGFactor,
  Value<int?> unitWeight,
  Value<String?> defaultUnits,
  Value<double?> edibleQtyPerUnit,
  Value<double?> kcal,
  Value<double> proteins,
  Value<double?> carbsByDifference,
  Value<double?> carbsAvailable,
  Value<double?> dietaryFiber,
  Value<double> fats,
  Value<bool> isSupplement,
  Value<bool> isPortable,
});

class $$ProductsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ProductsTable,
    Product,
    $$ProductsTableFilterComposer,
    $$ProductsTableOrderingComposer,
    $$ProductsTableProcessedTableManager,
    $$ProductsTableInsertCompanionBuilder,
    $$ProductsTableUpdateCompanionBuilder> {
  $$ProductsTableTableManager(_$AppDatabase db, $ProductsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$ProductsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$ProductsTableOrderingComposer(ComposerState(db, table)),
          getChildManagerBuilder: (p) =>
              $$ProductsTableProcessedTableManager(p),
          getUpdateCompanionBuilder: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<double> weight = const Value.absent(),
            Value<int?> mlToGFactor = const Value.absent(),
            Value<int?> unitWeight = const Value.absent(),
            Value<String?> defaultUnits = const Value.absent(),
            Value<double?> edibleQtyPerUnit = const Value.absent(),
            Value<double?> kcal = const Value.absent(),
            Value<double> proteins = const Value.absent(),
            Value<double?> carbsByDifference = const Value.absent(),
            Value<double?> carbsAvailable = const Value.absent(),
            Value<double?> dietaryFiber = const Value.absent(),
            Value<double> fats = const Value.absent(),
            Value<bool> isSupplement = const Value.absent(),
            Value<bool> isPortable = const Value.absent(),
          }) =>
              ProductsCompanion(
            id: id,
            name: name,
            weight: weight,
            mlToGFactor: mlToGFactor,
            unitWeight: unitWeight,
            defaultUnits: defaultUnits,
            edibleQtyPerUnit: edibleQtyPerUnit,
            kcal: kcal,
            proteins: proteins,
            carbsByDifference: carbsByDifference,
            carbsAvailable: carbsAvailable,
            dietaryFiber: dietaryFiber,
            fats: fats,
            isSupplement: isSupplement,
            isPortable: isPortable,
          ),
          getInsertCompanionBuilder: ({
            Value<int> id = const Value.absent(),
            required String name,
            required double weight,
            Value<int?> mlToGFactor = const Value.absent(),
            Value<int?> unitWeight = const Value.absent(),
            Value<String?> defaultUnits = const Value.absent(),
            Value<double?> edibleQtyPerUnit = const Value.absent(),
            Value<double?> kcal = const Value.absent(),
            required double proteins,
            Value<double?> carbsByDifference = const Value.absent(),
            Value<double?> carbsAvailable = const Value.absent(),
            Value<double?> dietaryFiber = const Value.absent(),
            required double fats,
            required bool isSupplement,
            Value<bool> isPortable = const Value.absent(),
          }) =>
              ProductsCompanion.insert(
            id: id,
            name: name,
            weight: weight,
            mlToGFactor: mlToGFactor,
            unitWeight: unitWeight,
            defaultUnits: defaultUnits,
            edibleQtyPerUnit: edibleQtyPerUnit,
            kcal: kcal,
            proteins: proteins,
            carbsByDifference: carbsByDifference,
            carbsAvailable: carbsAvailable,
            dietaryFiber: dietaryFiber,
            fats: fats,
            isSupplement: isSupplement,
            isPortable: isPortable,
          ),
        ));
}

class $$ProductsTableProcessedTableManager extends ProcessedTableManager<
    _$AppDatabase,
    $ProductsTable,
    Product,
    $$ProductsTableFilterComposer,
    $$ProductsTableOrderingComposer,
    $$ProductsTableProcessedTableManager,
    $$ProductsTableInsertCompanionBuilder,
    $$ProductsTableUpdateCompanionBuilder> {
  $$ProductsTableProcessedTableManager(super.$state);
}

class $$ProductsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get weight => $state.composableBuilder(
      column: $state.table.weight,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get mlToGFactor => $state.composableBuilder(
      column: $state.table.mlToGFactor,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get unitWeight => $state.composableBuilder(
      column: $state.table.unitWeight,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get defaultUnits => $state.composableBuilder(
      column: $state.table.defaultUnits,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get edibleQtyPerUnit => $state.composableBuilder(
      column: $state.table.edibleQtyPerUnit,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get kcal => $state.composableBuilder(
      column: $state.table.kcal,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get proteins => $state.composableBuilder(
      column: $state.table.proteins,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get carbsByDifference => $state.composableBuilder(
      column: $state.table.carbsByDifference,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get carbsAvailable => $state.composableBuilder(
      column: $state.table.carbsAvailable,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get dietaryFiber => $state.composableBuilder(
      column: $state.table.dietaryFiber,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get fats => $state.composableBuilder(
      column: $state.table.fats,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get isSupplement => $state.composableBuilder(
      column: $state.table.isSupplement,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get isPortable => $state.composableBuilder(
      column: $state.table.isPortable,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$ProductsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get weight => $state.composableBuilder(
      column: $state.table.weight,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get mlToGFactor => $state.composableBuilder(
      column: $state.table.mlToGFactor,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get unitWeight => $state.composableBuilder(
      column: $state.table.unitWeight,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get defaultUnits => $state.composableBuilder(
      column: $state.table.defaultUnits,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get edibleQtyPerUnit => $state.composableBuilder(
      column: $state.table.edibleQtyPerUnit,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get kcal => $state.composableBuilder(
      column: $state.table.kcal,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get proteins => $state.composableBuilder(
      column: $state.table.proteins,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get carbsByDifference => $state.composableBuilder(
      column: $state.table.carbsByDifference,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get carbsAvailable => $state.composableBuilder(
      column: $state.table.carbsAvailable,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get dietaryFiber => $state.composableBuilder(
      column: $state.table.dietaryFiber,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get fats => $state.composableBuilder(
      column: $state.table.fats,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get isSupplement => $state.composableBuilder(
      column: $state.table.isSupplement,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get isPortable => $state.composableBuilder(
      column: $state.table.isPortable,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$RecipesTableInsertCompanionBuilder = RecipesCompanion Function({
  Value<int> id,
  required String name,
  required String instructions,
  required bool isPortable,
});
typedef $$RecipesTableUpdateCompanionBuilder = RecipesCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String> instructions,
  Value<bool> isPortable,
});

class $$RecipesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RecipesTable,
    Recipe,
    $$RecipesTableFilterComposer,
    $$RecipesTableOrderingComposer,
    $$RecipesTableProcessedTableManager,
    $$RecipesTableInsertCompanionBuilder,
    $$RecipesTableUpdateCompanionBuilder> {
  $$RecipesTableTableManager(_$AppDatabase db, $RecipesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$RecipesTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$RecipesTableOrderingComposer(ComposerState(db, table)),
          getChildManagerBuilder: (p) => $$RecipesTableProcessedTableManager(p),
          getUpdateCompanionBuilder: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> instructions = const Value.absent(),
            Value<bool> isPortable = const Value.absent(),
          }) =>
              RecipesCompanion(
            id: id,
            name: name,
            instructions: instructions,
            isPortable: isPortable,
          ),
          getInsertCompanionBuilder: ({
            Value<int> id = const Value.absent(),
            required String name,
            required String instructions,
            required bool isPortable,
          }) =>
              RecipesCompanion.insert(
            id: id,
            name: name,
            instructions: instructions,
            isPortable: isPortable,
          ),
        ));
}

class $$RecipesTableProcessedTableManager extends ProcessedTableManager<
    _$AppDatabase,
    $RecipesTable,
    Recipe,
    $$RecipesTableFilterComposer,
    $$RecipesTableOrderingComposer,
    $$RecipesTableProcessedTableManager,
    $$RecipesTableInsertCompanionBuilder,
    $$RecipesTableUpdateCompanionBuilder> {
  $$RecipesTableProcessedTableManager(super.$state);
}

class $$RecipesTableFilterComposer
    extends FilterComposer<_$AppDatabase, $RecipesTable> {
  $$RecipesTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get instructions => $state.composableBuilder(
      column: $state.table.instructions,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get isPortable => $state.composableBuilder(
      column: $state.table.isPortable,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$RecipesTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $RecipesTable> {
  $$RecipesTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get instructions => $state.composableBuilder(
      column: $state.table.instructions,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get isPortable => $state.composableBuilder(
      column: $state.table.isPortable,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$RecipeIngredientsTableInsertCompanionBuilder
    = RecipeIngredientsCompanion Function({
  Value<int> id,
  required int recipeId,
  required int productId,
  required double amount,
  Value<String?> amountUnits,
});
typedef $$RecipeIngredientsTableUpdateCompanionBuilder
    = RecipeIngredientsCompanion Function({
  Value<int> id,
  Value<int> recipeId,
  Value<int> productId,
  Value<double> amount,
  Value<String?> amountUnits,
});

class $$RecipeIngredientsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RecipeIngredientsTable,
    RecipeIngredient,
    $$RecipeIngredientsTableFilterComposer,
    $$RecipeIngredientsTableOrderingComposer,
    $$RecipeIngredientsTableProcessedTableManager,
    $$RecipeIngredientsTableInsertCompanionBuilder,
    $$RecipeIngredientsTableUpdateCompanionBuilder> {
  $$RecipeIngredientsTableTableManager(
      _$AppDatabase db, $RecipeIngredientsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$RecipeIngredientsTableFilterComposer(ComposerState(db, table)),
          orderingComposer: $$RecipeIngredientsTableOrderingComposer(
              ComposerState(db, table)),
          getChildManagerBuilder: (p) =>
              $$RecipeIngredientsTableProcessedTableManager(p),
          getUpdateCompanionBuilder: ({
            Value<int> id = const Value.absent(),
            Value<int> recipeId = const Value.absent(),
            Value<int> productId = const Value.absent(),
            Value<double> amount = const Value.absent(),
            Value<String?> amountUnits = const Value.absent(),
          }) =>
              RecipeIngredientsCompanion(
            id: id,
            recipeId: recipeId,
            productId: productId,
            amount: amount,
            amountUnits: amountUnits,
          ),
          getInsertCompanionBuilder: ({
            Value<int> id = const Value.absent(),
            required int recipeId,
            required int productId,
            required double amount,
            Value<String?> amountUnits = const Value.absent(),
          }) =>
              RecipeIngredientsCompanion.insert(
            id: id,
            recipeId: recipeId,
            productId: productId,
            amount: amount,
            amountUnits: amountUnits,
          ),
        ));
}

class $$RecipeIngredientsTableProcessedTableManager
    extends ProcessedTableManager<
        _$AppDatabase,
        $RecipeIngredientsTable,
        RecipeIngredient,
        $$RecipeIngredientsTableFilterComposer,
        $$RecipeIngredientsTableOrderingComposer,
        $$RecipeIngredientsTableProcessedTableManager,
        $$RecipeIngredientsTableInsertCompanionBuilder,
        $$RecipeIngredientsTableUpdateCompanionBuilder> {
  $$RecipeIngredientsTableProcessedTableManager(super.$state);
}

class $$RecipeIngredientsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $RecipeIngredientsTable> {
  $$RecipeIngredientsTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get recipeId => $state.composableBuilder(
      column: $state.table.recipeId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get productId => $state.composableBuilder(
      column: $state.table.productId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get amount => $state.composableBuilder(
      column: $state.table.amount,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get amountUnits => $state.composableBuilder(
      column: $state.table.amountUnits,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$RecipeIngredientsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $RecipeIngredientsTable> {
  $$RecipeIngredientsTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get recipeId => $state.composableBuilder(
      column: $state.table.recipeId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get productId => $state.composableBuilder(
      column: $state.table.productId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get amount => $state.composableBuilder(
      column: $state.table.amount,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get amountUnits => $state.composableBuilder(
      column: $state.table.amountUnits,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$MealPlansTableInsertCompanionBuilder = MealPlansCompanion Function({
  Value<int> id,
  required int parentPlanId,
  required String title,
  required String notes,
  required MealPlanState state,
  required DateTime created,
  required DateTime completed,
  Value<double?> targetProtein,
  Value<double?> targetCarbs,
  Value<double?> targetFats,
  Value<bool> isTemporal,
});
typedef $$MealPlansTableUpdateCompanionBuilder = MealPlansCompanion Function({
  Value<int> id,
  Value<int> parentPlanId,
  Value<String> title,
  Value<String> notes,
  Value<MealPlanState> state,
  Value<DateTime> created,
  Value<DateTime> completed,
  Value<double?> targetProtein,
  Value<double?> targetCarbs,
  Value<double?> targetFats,
  Value<bool> isTemporal,
});

class $$MealPlansTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MealPlansTable,
    MealPlan,
    $$MealPlansTableFilterComposer,
    $$MealPlansTableOrderingComposer,
    $$MealPlansTableProcessedTableManager,
    $$MealPlansTableInsertCompanionBuilder,
    $$MealPlansTableUpdateCompanionBuilder> {
  $$MealPlansTableTableManager(_$AppDatabase db, $MealPlansTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$MealPlansTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$MealPlansTableOrderingComposer(ComposerState(db, table)),
          getChildManagerBuilder: (p) =>
              $$MealPlansTableProcessedTableManager(p),
          getUpdateCompanionBuilder: ({
            Value<int> id = const Value.absent(),
            Value<int> parentPlanId = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> notes = const Value.absent(),
            Value<MealPlanState> state = const Value.absent(),
            Value<DateTime> created = const Value.absent(),
            Value<DateTime> completed = const Value.absent(),
            Value<double?> targetProtein = const Value.absent(),
            Value<double?> targetCarbs = const Value.absent(),
            Value<double?> targetFats = const Value.absent(),
            Value<bool> isTemporal = const Value.absent(),
          }) =>
              MealPlansCompanion(
            id: id,
            parentPlanId: parentPlanId,
            title: title,
            notes: notes,
            state: state,
            created: created,
            completed: completed,
            targetProtein: targetProtein,
            targetCarbs: targetCarbs,
            targetFats: targetFats,
            isTemporal: isTemporal,
          ),
          getInsertCompanionBuilder: ({
            Value<int> id = const Value.absent(),
            required int parentPlanId,
            required String title,
            required String notes,
            required MealPlanState state,
            required DateTime created,
            required DateTime completed,
            Value<double?> targetProtein = const Value.absent(),
            Value<double?> targetCarbs = const Value.absent(),
            Value<double?> targetFats = const Value.absent(),
            Value<bool> isTemporal = const Value.absent(),
          }) =>
              MealPlansCompanion.insert(
            id: id,
            parentPlanId: parentPlanId,
            title: title,
            notes: notes,
            state: state,
            created: created,
            completed: completed,
            targetProtein: targetProtein,
            targetCarbs: targetCarbs,
            targetFats: targetFats,
            isTemporal: isTemporal,
          ),
        ));
}

class $$MealPlansTableProcessedTableManager extends ProcessedTableManager<
    _$AppDatabase,
    $MealPlansTable,
    MealPlan,
    $$MealPlansTableFilterComposer,
    $$MealPlansTableOrderingComposer,
    $$MealPlansTableProcessedTableManager,
    $$MealPlansTableInsertCompanionBuilder,
    $$MealPlansTableUpdateCompanionBuilder> {
  $$MealPlansTableProcessedTableManager(super.$state);
}

class $$MealPlansTableFilterComposer
    extends FilterComposer<_$AppDatabase, $MealPlansTable> {
  $$MealPlansTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get parentPlanId => $state.composableBuilder(
      column: $state.table.parentPlanId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get title => $state.composableBuilder(
      column: $state.table.title,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get notes => $state.composableBuilder(
      column: $state.table.notes,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnWithTypeConverterFilters<MealPlanState, MealPlanState, String>
      get state => $state.composableBuilder(
          column: $state.table.state,
          builder: (column, joinBuilders) => ColumnWithTypeConverterFilters(
              column,
              joinBuilders: joinBuilders));

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get created =>
      $state.composableBuilder(
          column: $state.table.created,
          builder: (column, joinBuilders) => ColumnWithTypeConverterFilters(
              column,
              joinBuilders: joinBuilders));

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get completed =>
      $state.composableBuilder(
          column: $state.table.completed,
          builder: (column, joinBuilders) => ColumnWithTypeConverterFilters(
              column,
              joinBuilders: joinBuilders));

  ColumnFilters<double> get targetProtein => $state.composableBuilder(
      column: $state.table.targetProtein,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get targetCarbs => $state.composableBuilder(
      column: $state.table.targetCarbs,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get targetFats => $state.composableBuilder(
      column: $state.table.targetFats,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get isTemporal => $state.composableBuilder(
      column: $state.table.isTemporal,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$MealPlansTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $MealPlansTable> {
  $$MealPlansTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get parentPlanId => $state.composableBuilder(
      column: $state.table.parentPlanId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get title => $state.composableBuilder(
      column: $state.table.title,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get notes => $state.composableBuilder(
      column: $state.table.notes,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get state => $state.composableBuilder(
      column: $state.table.state,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get created => $state.composableBuilder(
      column: $state.table.created,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get completed => $state.composableBuilder(
      column: $state.table.completed,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get targetProtein => $state.composableBuilder(
      column: $state.table.targetProtein,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get targetCarbs => $state.composableBuilder(
      column: $state.table.targetCarbs,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get targetFats => $state.composableBuilder(
      column: $state.table.targetFats,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get isTemporal => $state.composableBuilder(
      column: $state.table.isTemporal,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$MealsTableInsertCompanionBuilder = MealsCompanion Function({
  Value<int> id,
  required int mealPlanId,
  required String name,
  required LocalTime time,
  required String notes,
  required int position,
});
typedef $$MealsTableUpdateCompanionBuilder = MealsCompanion Function({
  Value<int> id,
  Value<int> mealPlanId,
  Value<String> name,
  Value<LocalTime> time,
  Value<String> notes,
  Value<int> position,
});

class $$MealsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MealsTable,
    Meal,
    $$MealsTableFilterComposer,
    $$MealsTableOrderingComposer,
    $$MealsTableProcessedTableManager,
    $$MealsTableInsertCompanionBuilder,
    $$MealsTableUpdateCompanionBuilder> {
  $$MealsTableTableManager(_$AppDatabase db, $MealsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$MealsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$MealsTableOrderingComposer(ComposerState(db, table)),
          getChildManagerBuilder: (p) => $$MealsTableProcessedTableManager(p),
          getUpdateCompanionBuilder: ({
            Value<int> id = const Value.absent(),
            Value<int> mealPlanId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<LocalTime> time = const Value.absent(),
            Value<String> notes = const Value.absent(),
            Value<int> position = const Value.absent(),
          }) =>
              MealsCompanion(
            id: id,
            mealPlanId: mealPlanId,
            name: name,
            time: time,
            notes: notes,
            position: position,
          ),
          getInsertCompanionBuilder: ({
            Value<int> id = const Value.absent(),
            required int mealPlanId,
            required String name,
            required LocalTime time,
            required String notes,
            required int position,
          }) =>
              MealsCompanion.insert(
            id: id,
            mealPlanId: mealPlanId,
            name: name,
            time: time,
            notes: notes,
            position: position,
          ),
        ));
}

class $$MealsTableProcessedTableManager extends ProcessedTableManager<
    _$AppDatabase,
    $MealsTable,
    Meal,
    $$MealsTableFilterComposer,
    $$MealsTableOrderingComposer,
    $$MealsTableProcessedTableManager,
    $$MealsTableInsertCompanionBuilder,
    $$MealsTableUpdateCompanionBuilder> {
  $$MealsTableProcessedTableManager(super.$state);
}

class $$MealsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $MealsTable> {
  $$MealsTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get mealPlanId => $state.composableBuilder(
      column: $state.table.mealPlanId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnWithTypeConverterFilters<LocalTime, LocalTime, String> get time =>
      $state.composableBuilder(
          column: $state.table.time,
          builder: (column, joinBuilders) => ColumnWithTypeConverterFilters(
              column,
              joinBuilders: joinBuilders));

  ColumnFilters<String> get notes => $state.composableBuilder(
      column: $state.table.notes,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get position => $state.composableBuilder(
      column: $state.table.position,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$MealsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $MealsTable> {
  $$MealsTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get mealPlanId => $state.composableBuilder(
      column: $state.table.mealPlanId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get time => $state.composableBuilder(
      column: $state.table.time,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get notes => $state.composableBuilder(
      column: $state.table.notes,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get position => $state.composableBuilder(
      column: $state.table.position,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$MealItemsTableInsertCompanionBuilder = MealItemsCompanion Function({
  Value<int> id,
  required int mealId,
  required MealItemType type,
  required int targetId,
  required double amount,
  Value<AmountUnit> amountUnit,
  required bool consumed,
  required int position,
});
typedef $$MealItemsTableUpdateCompanionBuilder = MealItemsCompanion Function({
  Value<int> id,
  Value<int> mealId,
  Value<MealItemType> type,
  Value<int> targetId,
  Value<double> amount,
  Value<AmountUnit> amountUnit,
  Value<bool> consumed,
  Value<int> position,
});

class $$MealItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MealItemsTable,
    MealItem,
    $$MealItemsTableFilterComposer,
    $$MealItemsTableOrderingComposer,
    $$MealItemsTableProcessedTableManager,
    $$MealItemsTableInsertCompanionBuilder,
    $$MealItemsTableUpdateCompanionBuilder> {
  $$MealItemsTableTableManager(_$AppDatabase db, $MealItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$MealItemsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$MealItemsTableOrderingComposer(ComposerState(db, table)),
          getChildManagerBuilder: (p) =>
              $$MealItemsTableProcessedTableManager(p),
          getUpdateCompanionBuilder: ({
            Value<int> id = const Value.absent(),
            Value<int> mealId = const Value.absent(),
            Value<MealItemType> type = const Value.absent(),
            Value<int> targetId = const Value.absent(),
            Value<double> amount = const Value.absent(),
            Value<AmountUnit> amountUnit = const Value.absent(),
            Value<bool> consumed = const Value.absent(),
            Value<int> position = const Value.absent(),
          }) =>
              MealItemsCompanion(
            id: id,
            mealId: mealId,
            type: type,
            targetId: targetId,
            amount: amount,
            amountUnit: amountUnit,
            consumed: consumed,
            position: position,
          ),
          getInsertCompanionBuilder: ({
            Value<int> id = const Value.absent(),
            required int mealId,
            required MealItemType type,
            required int targetId,
            required double amount,
            Value<AmountUnit> amountUnit = const Value.absent(),
            required bool consumed,
            required int position,
          }) =>
              MealItemsCompanion.insert(
            id: id,
            mealId: mealId,
            type: type,
            targetId: targetId,
            amount: amount,
            amountUnit: amountUnit,
            consumed: consumed,
            position: position,
          ),
        ));
}

class $$MealItemsTableProcessedTableManager extends ProcessedTableManager<
    _$AppDatabase,
    $MealItemsTable,
    MealItem,
    $$MealItemsTableFilterComposer,
    $$MealItemsTableOrderingComposer,
    $$MealItemsTableProcessedTableManager,
    $$MealItemsTableInsertCompanionBuilder,
    $$MealItemsTableUpdateCompanionBuilder> {
  $$MealItemsTableProcessedTableManager(super.$state);
}

class $$MealItemsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $MealItemsTable> {
  $$MealItemsTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get mealId => $state.composableBuilder(
      column: $state.table.mealId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnWithTypeConverterFilters<MealItemType, MealItemType, String> get type =>
      $state.composableBuilder(
          column: $state.table.type,
          builder: (column, joinBuilders) => ColumnWithTypeConverterFilters(
              column,
              joinBuilders: joinBuilders));

  ColumnFilters<int> get targetId => $state.composableBuilder(
      column: $state.table.targetId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get amount => $state.composableBuilder(
      column: $state.table.amount,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnWithTypeConverterFilters<AmountUnit, AmountUnit, String>
      get amountUnit => $state.composableBuilder(
          column: $state.table.amountUnit,
          builder: (column, joinBuilders) => ColumnWithTypeConverterFilters(
              column,
              joinBuilders: joinBuilders));

  ColumnFilters<bool> get consumed => $state.composableBuilder(
      column: $state.table.consumed,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get position => $state.composableBuilder(
      column: $state.table.position,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$MealItemsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $MealItemsTable> {
  $$MealItemsTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get mealId => $state.composableBuilder(
      column: $state.table.mealId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get type => $state.composableBuilder(
      column: $state.table.type,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get targetId => $state.composableBuilder(
      column: $state.table.targetId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get amount => $state.composableBuilder(
      column: $state.table.amount,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get amountUnit => $state.composableBuilder(
      column: $state.table.amountUnit,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get consumed => $state.composableBuilder(
      column: $state.table.consumed,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get position => $state.composableBuilder(
      column: $state.table.position,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

class _$AppDatabaseManager {
  final _$AppDatabase _db;
  _$AppDatabaseManager(this._db);
  $$WorkoutsTableTableManager get workouts =>
      $$WorkoutsTableTableManager(_db, _db.workouts);
  $$ExerciseDataTableTableManager get exerciseData =>
      $$ExerciseDataTableTableManager(_db, _db.exerciseData);
  $$ExercisesTableTableManager get exercises =>
      $$ExercisesTableTableManager(_db, _db.exercises);
  $$SetsTableTableManager get sets => $$SetsTableTableManager(_db, _db.sets);
  $$BodyMeasurementsTableTableManager get bodyMeasurements =>
      $$BodyMeasurementsTableTableManager(_db, _db.bodyMeasurements);
  $$AdvancedBodyMeasurementsTableTableManager get advancedBodyMeasurements =>
      $$AdvancedBodyMeasurementsTableTableManager(
          _db, _db.advancedBodyMeasurements);
  $$ActivityMeasurementsTableTableManager get activityMeasurements =>
      $$ActivityMeasurementsTableTableManager(_db, _db.activityMeasurements);
  $$SleepMeasurementsTableTableManager get sleepMeasurements =>
      $$SleepMeasurementsTableTableManager(_db, _db.sleepMeasurements);
  $$AdvancedSleepMeasurementsTableTableManager get advancedSleepMeasurements =>
      $$AdvancedSleepMeasurementsTableTableManager(
          _db, _db.advancedSleepMeasurements);
  $$ProductsTableTableManager get products =>
      $$ProductsTableTableManager(_db, _db.products);
  $$RecipesTableTableManager get recipes =>
      $$RecipesTableTableManager(_db, _db.recipes);
  $$RecipeIngredientsTableTableManager get recipeIngredients =>
      $$RecipeIngredientsTableTableManager(_db, _db.recipeIngredients);
  $$MealPlansTableTableManager get mealPlans =>
      $$MealPlansTableTableManager(_db, _db.mealPlans);
  $$MealsTableTableManager get meals =>
      $$MealsTableTableManager(_db, _db.meals);
  $$MealItemsTableTableManager get mealItems =>
      $$MealItemsTableTableManager(_db, _db.mealItems);
}
