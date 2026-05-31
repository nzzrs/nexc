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

class $DatasetTable extends Dataset with TableInfo<$DatasetTable, ExerciseDC> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DatasetTable(this.attachedDatabase, [this._alias]);
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
          .withConverter<Force?>($DatasetTable.$converterforcen);
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumnWithTypeConverter<Level, String> level =
      GeneratedColumn<String>('level', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<Level>($DatasetTable.$converterlevel);
  static const VerificationMeta _mechanicMeta =
      const VerificationMeta('mechanic');
  @override
  late final GeneratedColumnWithTypeConverter<Mechanic?, String> mechanic =
      GeneratedColumn<String>('mechanic', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<Mechanic?>($DatasetTable.$convertermechanicn);
  static const VerificationMeta _equipmentMeta =
      const VerificationMeta('equipment');
  @override
  late final GeneratedColumnWithTypeConverter<Equipment?, String> equipment =
      GeneratedColumn<String>('equipment', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<Equipment?>($DatasetTable.$converterequipmentn);
  static const VerificationMeta _primaryMusclesMeta =
      const VerificationMeta('primaryMuscles');
  @override
  late final GeneratedColumnWithTypeConverter<List<Muscle>, String>
      primaryMuscles = GeneratedColumn<String>(
              'primaryMuscles', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<List<Muscle>>($DatasetTable.$converterprimaryMuscles);
  static const VerificationMeta _secondaryMusclesMeta =
      const VerificationMeta('secondaryMuscles');
  @override
  late final GeneratedColumnWithTypeConverter<List<Muscle>, String>
      secondaryMuscles = GeneratedColumn<String>(
              'secondaryMuscles', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<List<Muscle>>(
              $DatasetTable.$convertersecondaryMuscles);
  static const VerificationMeta _instructionsMeta =
      const VerificationMeta('instructions');
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String>
      instructions = GeneratedColumn<String>('instructions', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<List<String>>($DatasetTable.$converterinstructions);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumnWithTypeConverter<Category, String> category =
      GeneratedColumn<String>('category', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<Category>($DatasetTable.$convertercategory);
  static const VerificationMeta _imagesMeta = const VerificationMeta('images');
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String> images =
      GeneratedColumn<String>('images', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<List<String>>($DatasetTable.$converterimages);
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
  static const String $name = 'dataset';
  @override
  VerificationContext validateIntegrity(Insertable<ExerciseDC> instance,
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
  ExerciseDC map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExerciseDC(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      force: $DatasetTable.$converterforcen.fromSql(attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}force'])),
      level: $DatasetTable.$converterlevel.fromSql(attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}level'])!),
      mechanic: $DatasetTable.$convertermechanicn.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}mechanic'])),
      equipment: $DatasetTable.$converterequipmentn.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}equipment'])),
      primaryMuscles: $DatasetTable.$converterprimaryMuscles.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}primaryMuscles'])!),
      secondaryMuscles: $DatasetTable.$convertersecondaryMuscles.fromSql(
          attachedDatabase.typeMapping.read(DriftSqlType.string,
              data['${effectivePrefix}secondaryMuscles'])!),
      instructions: $DatasetTable.$converterinstructions.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}instructions'])!),
      category: $DatasetTable.$convertercategory.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!),
      images: $DatasetTable.$converterimages.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}images'])!),
      isCustomExercise: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}isCustomExercise'])!,
    );
  }

  @override
  $DatasetTable createAlias(String alias) {
    return $DatasetTable(attachedDatabase, alias);
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

class ExerciseDC extends DataClass implements Insertable<ExerciseDC> {
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
  const ExerciseDC(
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
          Variable<String>($DatasetTable.$converterforcen.toSql(force));
    }
    {
      map['level'] =
          Variable<String>($DatasetTable.$converterlevel.toSql(level));
    }
    if (!nullToAbsent || mechanic != null) {
      map['mechanic'] =
          Variable<String>($DatasetTable.$convertermechanicn.toSql(mechanic));
    }
    if (!nullToAbsent || equipment != null) {
      map['equipment'] =
          Variable<String>($DatasetTable.$converterequipmentn.toSql(equipment));
    }
    {
      map['primaryMuscles'] = Variable<String>(
          $DatasetTable.$converterprimaryMuscles.toSql(primaryMuscles));
    }
    {
      map['secondaryMuscles'] = Variable<String>(
          $DatasetTable.$convertersecondaryMuscles.toSql(secondaryMuscles));
    }
    {
      map['instructions'] = Variable<String>(
          $DatasetTable.$converterinstructions.toSql(instructions));
    }
    {
      map['category'] =
          Variable<String>($DatasetTable.$convertercategory.toSql(category));
    }
    {
      map['images'] =
          Variable<String>($DatasetTable.$converterimages.toSql(images));
    }
    map['isCustomExercise'] = Variable<bool>(isCustomExercise);
    return map;
  }

  DatasetCompanion toCompanion(bool nullToAbsent) {
    return DatasetCompanion(
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

  factory ExerciseDC.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExerciseDC(
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

  ExerciseDC copyWith(
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
      ExerciseDC(
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
    return (StringBuffer('ExerciseDC(')
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
      (other is ExerciseDC &&
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

class DatasetCompanion extends UpdateCompanion<ExerciseDC> {
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
  const DatasetCompanion({
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
  DatasetCompanion.insert({
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
  static Insertable<ExerciseDC> custom({
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

  DatasetCompanion copyWith(
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
    return DatasetCompanion(
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
      map['force'] =
          Variable<String>($DatasetTable.$converterforcen.toSql(force.value));
    }
    if (level.present) {
      map['level'] =
          Variable<String>($DatasetTable.$converterlevel.toSql(level.value));
    }
    if (mechanic.present) {
      map['mechanic'] = Variable<String>(
          $DatasetTable.$convertermechanicn.toSql(mechanic.value));
    }
    if (equipment.present) {
      map['equipment'] = Variable<String>(
          $DatasetTable.$converterequipmentn.toSql(equipment.value));
    }
    if (primaryMuscles.present) {
      map['primaryMuscles'] = Variable<String>(
          $DatasetTable.$converterprimaryMuscles.toSql(primaryMuscles.value));
    }
    if (secondaryMuscles.present) {
      map['secondaryMuscles'] = Variable<String>($DatasetTable
          .$convertersecondaryMuscles
          .toSql(secondaryMuscles.value));
    }
    if (instructions.present) {
      map['instructions'] = Variable<String>(
          $DatasetTable.$converterinstructions.toSql(instructions.value));
    }
    if (category.present) {
      map['category'] = Variable<String>(
          $DatasetTable.$convertercategory.toSql(category.value));
    }
    if (images.present) {
      map['images'] =
          Variable<String>($DatasetTable.$converterimages.toSql(images.value));
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
    return (StringBuffer('DatasetCompanion(')
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
  static const VerificationMeta _idExerciseDCMeta =
      const VerificationMeta('idExerciseDC');
  @override
  late final GeneratedColumn<String> idExerciseDC = GeneratedColumn<String>(
      'idExerciseDC', aliasedName, false,
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
        idExerciseDC,
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
    if (data.containsKey('idExerciseDC')) {
      context.handle(
          _idExerciseDCMeta,
          idExerciseDC.isAcceptableOrUnknown(
              data['idExerciseDC']!, _idExerciseDCMeta));
    } else if (isInserting) {
      context.missing(_idExerciseDCMeta);
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
      idExerciseDC: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}idExerciseDC'])!,
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
  final String idExerciseDC;
  final String notes;
  final SetMode setMode;
  final int restTime;
  final int position;
  final int? supersetId;
  final int workoutId;
  const Exercise(
      {required this.id,
      required this.idExerciseDC,
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
    map['idExerciseDC'] = Variable<String>(idExerciseDC);
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
      idExerciseDC: Value(idExerciseDC),
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
      idExerciseDC: serializer.fromJson<String>(json['idExerciseDC']),
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
      'idExerciseDC': serializer.toJson<String>(idExerciseDC),
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
          String? idExerciseDC,
          String? notes,
          SetMode? setMode,
          int? restTime,
          int? position,
          Value<int?> supersetId = const Value.absent(),
          int? workoutId}) =>
      Exercise(
        id: id ?? this.id,
        idExerciseDC: idExerciseDC ?? this.idExerciseDC,
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
          ..write('idExerciseDC: $idExerciseDC, ')
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
  int get hashCode => Object.hash(id, idExerciseDC, notes, setMode, restTime,
      position, supersetId, workoutId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Exercise &&
          other.id == this.id &&
          other.idExerciseDC == this.idExerciseDC &&
          other.notes == this.notes &&
          other.setMode == this.setMode &&
          other.restTime == this.restTime &&
          other.position == this.position &&
          other.supersetId == this.supersetId &&
          other.workoutId == this.workoutId);
}

class ExercisesCompanion extends UpdateCompanion<Exercise> {
  final Value<int> id;
  final Value<String> idExerciseDC;
  final Value<String> notes;
  final Value<SetMode> setMode;
  final Value<int> restTime;
  final Value<int> position;
  final Value<int?> supersetId;
  final Value<int> workoutId;
  const ExercisesCompanion({
    this.id = const Value.absent(),
    this.idExerciseDC = const Value.absent(),
    this.notes = const Value.absent(),
    this.setMode = const Value.absent(),
    this.restTime = const Value.absent(),
    this.position = const Value.absent(),
    this.supersetId = const Value.absent(),
    this.workoutId = const Value.absent(),
  });
  ExercisesCompanion.insert({
    this.id = const Value.absent(),
    required String idExerciseDC,
    required String notes,
    required SetMode setMode,
    required int restTime,
    this.position = const Value.absent(),
    this.supersetId = const Value.absent(),
    required int workoutId,
  })  : idExerciseDC = Value(idExerciseDC),
        notes = Value(notes),
        setMode = Value(setMode),
        restTime = Value(restTime),
        workoutId = Value(workoutId);
  static Insertable<Exercise> custom({
    Expression<int>? id,
    Expression<String>? idExerciseDC,
    Expression<String>? notes,
    Expression<String>? setMode,
    Expression<int>? restTime,
    Expression<int>? position,
    Expression<int>? supersetId,
    Expression<int>? workoutId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (idExerciseDC != null) 'idExerciseDC': idExerciseDC,
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
      Value<String>? idExerciseDC,
      Value<String>? notes,
      Value<SetMode>? setMode,
      Value<int>? restTime,
      Value<int>? position,
      Value<int?>? supersetId,
      Value<int>? workoutId}) {
    return ExercisesCompanion(
      id: id ?? this.id,
      idExerciseDC: idExerciseDC ?? this.idExerciseDC,
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
    if (idExerciseDC.present) {
      map['idExerciseDC'] = Variable<String>(idExerciseDC.value);
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
          ..write('idExerciseDC: $idExerciseDC, ')
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
  static const VerificationMeta _intensityScaleMeta =
      const VerificationMeta('intensityScale');
  @override
  late final GeneratedColumn<int> intensityScale = GeneratedColumn<int>(
      'intensityScale', aliasedName, true,
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
        intensityScale,
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
    if (data.containsKey('intensityScale')) {
      context.handle(
          _intensityScaleMeta,
          intensityScale.isAcceptableOrUnknown(
              data['intensityScale']!, _intensityScaleMeta));
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
      intensityScale: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}intensityScale']),
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
  final int? intensityScale;
  final int exerciseId;
  const WorkoutSet(
      {required this.id,
      required this.load,
      required this.reps,
      required this.elapsedTime,
      required this.completed,
      this.rpe,
      this.rir,
      this.intensityScale,
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
    if (!nullToAbsent || intensityScale != null) {
      map['intensityScale'] = Variable<int>(intensityScale);
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
      intensityScale: intensityScale == null && nullToAbsent
          ? const Value.absent()
          : Value(intensityScale),
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
      intensityScale: serializer.fromJson<int?>(json['intensityScale']),
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
      'intensityScale': serializer.toJson<int?>(intensityScale),
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
          Value<int?> intensityScale = const Value.absent(),
          int? exerciseId}) =>
      WorkoutSet(
        id: id ?? this.id,
        load: load ?? this.load,
        reps: reps ?? this.reps,
        elapsedTime: elapsedTime ?? this.elapsedTime,
        completed: completed ?? this.completed,
        rpe: rpe.present ? rpe.value : this.rpe,
        rir: rir.present ? rir.value : this.rir,
        intensityScale:
            intensityScale.present ? intensityScale.value : this.intensityScale,
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
          ..write('intensityScale: $intensityScale, ')
          ..write('exerciseId: $exerciseId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, load, reps, elapsedTime, completed, rpe,
      rir, intensityScale, exerciseId);
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
          other.intensityScale == this.intensityScale &&
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
  final Value<int?> intensityScale;
  final Value<int> exerciseId;
  const SetsCompanion({
    this.id = const Value.absent(),
    this.load = const Value.absent(),
    this.reps = const Value.absent(),
    this.elapsedTime = const Value.absent(),
    this.completed = const Value.absent(),
    this.rpe = const Value.absent(),
    this.rir = const Value.absent(),
    this.intensityScale = const Value.absent(),
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
    this.intensityScale = const Value.absent(),
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
    Expression<int>? intensityScale,
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
      if (intensityScale != null) 'intensityScale': intensityScale,
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
      Value<int?>? intensityScale,
      Value<int>? exerciseId}) {
    return SetsCompanion(
      id: id ?? this.id,
      load: load ?? this.load,
      reps: reps ?? this.reps,
      elapsedTime: elapsedTime ?? this.elapsedTime,
      completed: completed ?? this.completed,
      rpe: rpe ?? this.rpe,
      rir: rir ?? this.rir,
      intensityScale: intensityScale ?? this.intensityScale,
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
    if (intensityScale.present) {
      map['intensityScale'] = Variable<int>(intensityScale.value);
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
          ..write('intensityScale: $intensityScale, ')
          ..write('exerciseId: $exerciseId')
          ..write(')'))
        .toString();
  }
}

class $MeasurementsTable extends Measurements
    with TableInfo<$MeasurementsTable, Measurement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MeasurementsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _bodyFatPercentageMeta =
      const VerificationMeta('bodyFatPercentage');
  @override
  late final GeneratedColumn<int> bodyFatPercentage = GeneratedColumn<int>(
      'bodyFatPercentage', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _muscleMassPercentageMeta =
      const VerificationMeta('muscleMassPercentage');
  @override
  late final GeneratedColumn<int> muscleMassPercentage = GeneratedColumn<int>(
      'muscleMassPercentage', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> date =
      GeneratedColumn<String>('date', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<DateTime>($MeasurementsTable.$converterdate);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, bodyWeight, bodyFatPercentage, muscleMassPercentage, date, notes];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'measurements';
  @override
  VerificationContext validateIntegrity(Insertable<Measurement> instance,
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
    if (data.containsKey('bodyFatPercentage')) {
      context.handle(
          _bodyFatPercentageMeta,
          bodyFatPercentage.isAcceptableOrUnknown(
              data['bodyFatPercentage']!, _bodyFatPercentageMeta));
    } else if (isInserting) {
      context.missing(_bodyFatPercentageMeta);
    }
    if (data.containsKey('muscleMassPercentage')) {
      context.handle(
          _muscleMassPercentageMeta,
          muscleMassPercentage.isAcceptableOrUnknown(
              data['muscleMassPercentage']!, _muscleMassPercentageMeta));
    } else if (isInserting) {
      context.missing(_muscleMassPercentageMeta);
    }
    context.handle(_dateMeta, const VerificationResult.success());
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    } else if (isInserting) {
      context.missing(_notesMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Measurement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Measurement(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      bodyWeight: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}bodyWeight'])!,
      bodyFatPercentage: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}bodyFatPercentage'])!,
      muscleMassPercentage: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}muscleMassPercentage'])!,
      date: $MeasurementsTable.$converterdate.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}date'])!),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes'])!,
    );
  }

  @override
  $MeasurementsTable createAlias(String alias) {
    return $MeasurementsTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, String> $converterdate =
      const IsoDateTimeConverter();
}

class Measurement extends DataClass implements Insertable<Measurement> {
  final int id;
  final double bodyWeight;
  final int bodyFatPercentage;
  final int muscleMassPercentage;
  final DateTime date;
  final String notes;
  const Measurement(
      {required this.id,
      required this.bodyWeight,
      required this.bodyFatPercentage,
      required this.muscleMassPercentage,
      required this.date,
      required this.notes});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['bodyWeight'] = Variable<double>(bodyWeight);
    map['bodyFatPercentage'] = Variable<int>(bodyFatPercentage);
    map['muscleMassPercentage'] = Variable<int>(muscleMassPercentage);
    {
      map['date'] =
          Variable<String>($MeasurementsTable.$converterdate.toSql(date));
    }
    map['notes'] = Variable<String>(notes);
    return map;
  }

  MeasurementsCompanion toCompanion(bool nullToAbsent) {
    return MeasurementsCompanion(
      id: Value(id),
      bodyWeight: Value(bodyWeight),
      bodyFatPercentage: Value(bodyFatPercentage),
      muscleMassPercentage: Value(muscleMassPercentage),
      date: Value(date),
      notes: Value(notes),
    );
  }

  factory Measurement.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Measurement(
      id: serializer.fromJson<int>(json['id']),
      bodyWeight: serializer.fromJson<double>(json['bodyWeight']),
      bodyFatPercentage: serializer.fromJson<int>(json['bodyFatPercentage']),
      muscleMassPercentage:
          serializer.fromJson<int>(json['muscleMassPercentage']),
      date: serializer.fromJson<DateTime>(json['date']),
      notes: serializer.fromJson<String>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'bodyWeight': serializer.toJson<double>(bodyWeight),
      'bodyFatPercentage': serializer.toJson<int>(bodyFatPercentage),
      'muscleMassPercentage': serializer.toJson<int>(muscleMassPercentage),
      'date': serializer.toJson<DateTime>(date),
      'notes': serializer.toJson<String>(notes),
    };
  }

  Measurement copyWith(
          {int? id,
          double? bodyWeight,
          int? bodyFatPercentage,
          int? muscleMassPercentage,
          DateTime? date,
          String? notes}) =>
      Measurement(
        id: id ?? this.id,
        bodyWeight: bodyWeight ?? this.bodyWeight,
        bodyFatPercentage: bodyFatPercentage ?? this.bodyFatPercentage,
        muscleMassPercentage: muscleMassPercentage ?? this.muscleMassPercentage,
        date: date ?? this.date,
        notes: notes ?? this.notes,
      );
  @override
  String toString() {
    return (StringBuffer('Measurement(')
          ..write('id: $id, ')
          ..write('bodyWeight: $bodyWeight, ')
          ..write('bodyFatPercentage: $bodyFatPercentage, ')
          ..write('muscleMassPercentage: $muscleMassPercentage, ')
          ..write('date: $date, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, bodyWeight, bodyFatPercentage, muscleMassPercentage, date, notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Measurement &&
          other.id == this.id &&
          other.bodyWeight == this.bodyWeight &&
          other.bodyFatPercentage == this.bodyFatPercentage &&
          other.muscleMassPercentage == this.muscleMassPercentage &&
          other.date == this.date &&
          other.notes == this.notes);
}

class MeasurementsCompanion extends UpdateCompanion<Measurement> {
  final Value<int> id;
  final Value<double> bodyWeight;
  final Value<int> bodyFatPercentage;
  final Value<int> muscleMassPercentage;
  final Value<DateTime> date;
  final Value<String> notes;
  const MeasurementsCompanion({
    this.id = const Value.absent(),
    this.bodyWeight = const Value.absent(),
    this.bodyFatPercentage = const Value.absent(),
    this.muscleMassPercentage = const Value.absent(),
    this.date = const Value.absent(),
    this.notes = const Value.absent(),
  });
  MeasurementsCompanion.insert({
    this.id = const Value.absent(),
    required double bodyWeight,
    required int bodyFatPercentage,
    required int muscleMassPercentage,
    required DateTime date,
    required String notes,
  })  : bodyWeight = Value(bodyWeight),
        bodyFatPercentage = Value(bodyFatPercentage),
        muscleMassPercentage = Value(muscleMassPercentage),
        date = Value(date),
        notes = Value(notes);
  static Insertable<Measurement> custom({
    Expression<int>? id,
    Expression<double>? bodyWeight,
    Expression<int>? bodyFatPercentage,
    Expression<int>? muscleMassPercentage,
    Expression<String>? date,
    Expression<String>? notes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bodyWeight != null) 'bodyWeight': bodyWeight,
      if (bodyFatPercentage != null) 'bodyFatPercentage': bodyFatPercentage,
      if (muscleMassPercentage != null)
        'muscleMassPercentage': muscleMassPercentage,
      if (date != null) 'date': date,
      if (notes != null) 'notes': notes,
    });
  }

  MeasurementsCompanion copyWith(
      {Value<int>? id,
      Value<double>? bodyWeight,
      Value<int>? bodyFatPercentage,
      Value<int>? muscleMassPercentage,
      Value<DateTime>? date,
      Value<String>? notes}) {
    return MeasurementsCompanion(
      id: id ?? this.id,
      bodyWeight: bodyWeight ?? this.bodyWeight,
      bodyFatPercentage: bodyFatPercentage ?? this.bodyFatPercentage,
      muscleMassPercentage: muscleMassPercentage ?? this.muscleMassPercentage,
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
    if (bodyWeight.present) {
      map['bodyWeight'] = Variable<double>(bodyWeight.value);
    }
    if (bodyFatPercentage.present) {
      map['bodyFatPercentage'] = Variable<int>(bodyFatPercentage.value);
    }
    if (muscleMassPercentage.present) {
      map['muscleMassPercentage'] = Variable<int>(muscleMassPercentage.value);
    }
    if (date.present) {
      map['date'] =
          Variable<String>($MeasurementsTable.$converterdate.toSql(date.value));
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MeasurementsCompanion(')
          ..write('id: $id, ')
          ..write('bodyWeight: $bodyWeight, ')
          ..write('bodyFatPercentage: $bodyFatPercentage, ')
          ..write('muscleMassPercentage: $muscleMassPercentage, ')
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
  static const VerificationMeta _costMeta = const VerificationMeta('cost');
  @override
  late final GeneratedColumn<double> cost = GeneratedColumn<double>(
      'cost', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
      'quantity', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _unitsMeta = const VerificationMeta('units');
  @override
  late final GeneratedColumn<String> units = GeneratedColumn<String>(
      'units', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _ediblePercentMeta =
      const VerificationMeta('ediblePercent');
  @override
  late final GeneratedColumn<double> ediblePercent = GeneratedColumn<double>(
      'ediblePercent', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _edibleQtyPerUnitMeta =
      const VerificationMeta('edibleQtyPerUnit');
  @override
  late final GeneratedColumn<double> edibleQtyPerUnit = GeneratedColumn<double>(
      'edibleQtyPerUnit', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _proteinsMeta =
      const VerificationMeta('proteins');
  @override
  late final GeneratedColumn<double> proteins = GeneratedColumn<double>(
      'proteins', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _carbsMeta = const VerificationMeta('carbs');
  @override
  late final GeneratedColumn<double> carbs = GeneratedColumn<double>(
      'carbs', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
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
        cost,
        quantity,
        units,
        ediblePercent,
        edibleQtyPerUnit,
        proteins,
        carbs,
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
    if (data.containsKey('cost')) {
      context.handle(
          _costMeta, cost.isAcceptableOrUnknown(data['cost']!, _costMeta));
    } else if (isInserting) {
      context.missing(_costMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('units')) {
      context.handle(
          _unitsMeta, units.isAcceptableOrUnknown(data['units']!, _unitsMeta));
    } else if (isInserting) {
      context.missing(_unitsMeta);
    }
    if (data.containsKey('ediblePercent')) {
      context.handle(
          _ediblePercentMeta,
          ediblePercent.isAcceptableOrUnknown(
              data['ediblePercent']!, _ediblePercentMeta));
    } else if (isInserting) {
      context.missing(_ediblePercentMeta);
    }
    if (data.containsKey('edibleQtyPerUnit')) {
      context.handle(
          _edibleQtyPerUnitMeta,
          edibleQtyPerUnit.isAcceptableOrUnknown(
              data['edibleQtyPerUnit']!, _edibleQtyPerUnitMeta));
    } else if (isInserting) {
      context.missing(_edibleQtyPerUnitMeta);
    }
    if (data.containsKey('proteins')) {
      context.handle(_proteinsMeta,
          proteins.isAcceptableOrUnknown(data['proteins']!, _proteinsMeta));
    } else if (isInserting) {
      context.missing(_proteinsMeta);
    }
    if (data.containsKey('carbs')) {
      context.handle(
          _carbsMeta, carbs.isAcceptableOrUnknown(data['carbs']!, _carbsMeta));
    } else if (isInserting) {
      context.missing(_carbsMeta);
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
      cost: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}cost'])!,
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}quantity'])!,
      units: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}units'])!,
      ediblePercent: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}ediblePercent'])!,
      edibleQtyPerUnit: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}edibleQtyPerUnit'])!,
      proteins: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}proteins'])!,
      carbs: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}carbs'])!,
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
  final double cost;
  final int quantity;
  final String units;
  final double ediblePercent;
  final double edibleQtyPerUnit;
  final double proteins;
  final double carbs;
  final double fats;
  final bool isSupplement;
  final bool isPortable;
  const Product(
      {required this.id,
      required this.name,
      required this.weight,
      required this.cost,
      required this.quantity,
      required this.units,
      required this.ediblePercent,
      required this.edibleQtyPerUnit,
      required this.proteins,
      required this.carbs,
      required this.fats,
      required this.isSupplement,
      required this.isPortable});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['weight'] = Variable<double>(weight);
    map['cost'] = Variable<double>(cost);
    map['quantity'] = Variable<int>(quantity);
    map['units'] = Variable<String>(units);
    map['ediblePercent'] = Variable<double>(ediblePercent);
    map['edibleQtyPerUnit'] = Variable<double>(edibleQtyPerUnit);
    map['proteins'] = Variable<double>(proteins);
    map['carbs'] = Variable<double>(carbs);
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
      cost: Value(cost),
      quantity: Value(quantity),
      units: Value(units),
      ediblePercent: Value(ediblePercent),
      edibleQtyPerUnit: Value(edibleQtyPerUnit),
      proteins: Value(proteins),
      carbs: Value(carbs),
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
      cost: serializer.fromJson<double>(json['cost']),
      quantity: serializer.fromJson<int>(json['quantity']),
      units: serializer.fromJson<String>(json['units']),
      ediblePercent: serializer.fromJson<double>(json['ediblePercent']),
      edibleQtyPerUnit: serializer.fromJson<double>(json['edibleQtyPerUnit']),
      proteins: serializer.fromJson<double>(json['proteins']),
      carbs: serializer.fromJson<double>(json['carbs']),
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
      'cost': serializer.toJson<double>(cost),
      'quantity': serializer.toJson<int>(quantity),
      'units': serializer.toJson<String>(units),
      'ediblePercent': serializer.toJson<double>(ediblePercent),
      'edibleQtyPerUnit': serializer.toJson<double>(edibleQtyPerUnit),
      'proteins': serializer.toJson<double>(proteins),
      'carbs': serializer.toJson<double>(carbs),
      'fats': serializer.toJson<double>(fats),
      'isSupplement': serializer.toJson<bool>(isSupplement),
      'isPortable': serializer.toJson<bool>(isPortable),
    };
  }

  Product copyWith(
          {int? id,
          String? name,
          double? weight,
          double? cost,
          int? quantity,
          String? units,
          double? ediblePercent,
          double? edibleQtyPerUnit,
          double? proteins,
          double? carbs,
          double? fats,
          bool? isSupplement,
          bool? isPortable}) =>
      Product(
        id: id ?? this.id,
        name: name ?? this.name,
        weight: weight ?? this.weight,
        cost: cost ?? this.cost,
        quantity: quantity ?? this.quantity,
        units: units ?? this.units,
        ediblePercent: ediblePercent ?? this.ediblePercent,
        edibleQtyPerUnit: edibleQtyPerUnit ?? this.edibleQtyPerUnit,
        proteins: proteins ?? this.proteins,
        carbs: carbs ?? this.carbs,
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
          ..write('cost: $cost, ')
          ..write('quantity: $quantity, ')
          ..write('units: $units, ')
          ..write('ediblePercent: $ediblePercent, ')
          ..write('edibleQtyPerUnit: $edibleQtyPerUnit, ')
          ..write('proteins: $proteins, ')
          ..write('carbs: $carbs, ')
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
      cost,
      quantity,
      units,
      ediblePercent,
      edibleQtyPerUnit,
      proteins,
      carbs,
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
          other.cost == this.cost &&
          other.quantity == this.quantity &&
          other.units == this.units &&
          other.ediblePercent == this.ediblePercent &&
          other.edibleQtyPerUnit == this.edibleQtyPerUnit &&
          other.proteins == this.proteins &&
          other.carbs == this.carbs &&
          other.fats == this.fats &&
          other.isSupplement == this.isSupplement &&
          other.isPortable == this.isPortable);
}

class ProductsCompanion extends UpdateCompanion<Product> {
  final Value<int> id;
  final Value<String> name;
  final Value<double> weight;
  final Value<double> cost;
  final Value<int> quantity;
  final Value<String> units;
  final Value<double> ediblePercent;
  final Value<double> edibleQtyPerUnit;
  final Value<double> proteins;
  final Value<double> carbs;
  final Value<double> fats;
  final Value<bool> isSupplement;
  final Value<bool> isPortable;
  const ProductsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.weight = const Value.absent(),
    this.cost = const Value.absent(),
    this.quantity = const Value.absent(),
    this.units = const Value.absent(),
    this.ediblePercent = const Value.absent(),
    this.edibleQtyPerUnit = const Value.absent(),
    this.proteins = const Value.absent(),
    this.carbs = const Value.absent(),
    this.fats = const Value.absent(),
    this.isSupplement = const Value.absent(),
    this.isPortable = const Value.absent(),
  });
  ProductsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required double weight,
    required double cost,
    required int quantity,
    required String units,
    required double ediblePercent,
    required double edibleQtyPerUnit,
    required double proteins,
    required double carbs,
    required double fats,
    required bool isSupplement,
    this.isPortable = const Value.absent(),
  })  : name = Value(name),
        weight = Value(weight),
        cost = Value(cost),
        quantity = Value(quantity),
        units = Value(units),
        ediblePercent = Value(ediblePercent),
        edibleQtyPerUnit = Value(edibleQtyPerUnit),
        proteins = Value(proteins),
        carbs = Value(carbs),
        fats = Value(fats),
        isSupplement = Value(isSupplement);
  static Insertable<Product> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<double>? weight,
    Expression<double>? cost,
    Expression<int>? quantity,
    Expression<String>? units,
    Expression<double>? ediblePercent,
    Expression<double>? edibleQtyPerUnit,
    Expression<double>? proteins,
    Expression<double>? carbs,
    Expression<double>? fats,
    Expression<bool>? isSupplement,
    Expression<bool>? isPortable,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (weight != null) 'weight': weight,
      if (cost != null) 'cost': cost,
      if (quantity != null) 'quantity': quantity,
      if (units != null) 'units': units,
      if (ediblePercent != null) 'ediblePercent': ediblePercent,
      if (edibleQtyPerUnit != null) 'edibleQtyPerUnit': edibleQtyPerUnit,
      if (proteins != null) 'proteins': proteins,
      if (carbs != null) 'carbs': carbs,
      if (fats != null) 'fats': fats,
      if (isSupplement != null) 'isSupplement': isSupplement,
      if (isPortable != null) 'isPortable': isPortable,
    });
  }

  ProductsCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<double>? weight,
      Value<double>? cost,
      Value<int>? quantity,
      Value<String>? units,
      Value<double>? ediblePercent,
      Value<double>? edibleQtyPerUnit,
      Value<double>? proteins,
      Value<double>? carbs,
      Value<double>? fats,
      Value<bool>? isSupplement,
      Value<bool>? isPortable}) {
    return ProductsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      weight: weight ?? this.weight,
      cost: cost ?? this.cost,
      quantity: quantity ?? this.quantity,
      units: units ?? this.units,
      ediblePercent: ediblePercent ?? this.ediblePercent,
      edibleQtyPerUnit: edibleQtyPerUnit ?? this.edibleQtyPerUnit,
      proteins: proteins ?? this.proteins,
      carbs: carbs ?? this.carbs,
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
    if (cost.present) {
      map['cost'] = Variable<double>(cost.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (units.present) {
      map['units'] = Variable<String>(units.value);
    }
    if (ediblePercent.present) {
      map['ediblePercent'] = Variable<double>(ediblePercent.value);
    }
    if (edibleQtyPerUnit.present) {
      map['edibleQtyPerUnit'] = Variable<double>(edibleQtyPerUnit.value);
    }
    if (proteins.present) {
      map['proteins'] = Variable<double>(proteins.value);
    }
    if (carbs.present) {
      map['carbs'] = Variable<double>(carbs.value);
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
          ..write('cost: $cost, ')
          ..write('quantity: $quantity, ')
          ..write('units: $units, ')
          ..write('ediblePercent: $ediblePercent, ')
          ..write('edibleQtyPerUnit: $edibleQtyPerUnit, ')
          ..write('proteins: $proteins, ')
          ..write('carbs: $carbs, ')
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
  @override
  List<GeneratedColumn> get $columns => [id, recipeId, productId, amount];
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
  const RecipeIngredient(
      {required this.id,
      required this.recipeId,
      required this.productId,
      required this.amount});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['recipeId'] = Variable<int>(recipeId);
    map['productId'] = Variable<int>(productId);
    map['amount'] = Variable<double>(amount);
    return map;
  }

  RecipeIngredientsCompanion toCompanion(bool nullToAbsent) {
    return RecipeIngredientsCompanion(
      id: Value(id),
      recipeId: Value(recipeId),
      productId: Value(productId),
      amount: Value(amount),
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
    };
  }

  RecipeIngredient copyWith(
          {int? id, int? recipeId, int? productId, double? amount}) =>
      RecipeIngredient(
        id: id ?? this.id,
        recipeId: recipeId ?? this.recipeId,
        productId: productId ?? this.productId,
        amount: amount ?? this.amount,
      );
  @override
  String toString() {
    return (StringBuffer('RecipeIngredient(')
          ..write('id: $id, ')
          ..write('recipeId: $recipeId, ')
          ..write('productId: $productId, ')
          ..write('amount: $amount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, recipeId, productId, amount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecipeIngredient &&
          other.id == this.id &&
          other.recipeId == this.recipeId &&
          other.productId == this.productId &&
          other.amount == this.amount);
}

class RecipeIngredientsCompanion extends UpdateCompanion<RecipeIngredient> {
  final Value<int> id;
  final Value<int> recipeId;
  final Value<int> productId;
  final Value<double> amount;
  const RecipeIngredientsCompanion({
    this.id = const Value.absent(),
    this.recipeId = const Value.absent(),
    this.productId = const Value.absent(),
    this.amount = const Value.absent(),
  });
  RecipeIngredientsCompanion.insert({
    this.id = const Value.absent(),
    required int recipeId,
    required int productId,
    required double amount,
  })  : recipeId = Value(recipeId),
        productId = Value(productId),
        amount = Value(amount);
  static Insertable<RecipeIngredient> custom({
    Expression<int>? id,
    Expression<int>? recipeId,
    Expression<int>? productId,
    Expression<double>? amount,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (recipeId != null) 'recipeId': recipeId,
      if (productId != null) 'productId': productId,
      if (amount != null) 'amount': amount,
    });
  }

  RecipeIngredientsCompanion copyWith(
      {Value<int>? id,
      Value<int>? recipeId,
      Value<int>? productId,
      Value<double>? amount}) {
    return RecipeIngredientsCompanion(
      id: id ?? this.id,
      recipeId: recipeId ?? this.recipeId,
      productId: productId ?? this.productId,
      amount: amount ?? this.amount,
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
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecipeIngredientsCompanion(')
          ..write('id: $id, ')
          ..write('recipeId: $recipeId, ')
          ..write('productId: $productId, ')
          ..write('amount: $amount')
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
  @override
  List<GeneratedColumn> get $columns =>
      [id, parentPlanId, title, notes, state, created, completed];
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
  const MealPlan(
      {required this.id,
      required this.parentPlanId,
      required this.title,
      required this.notes,
      required this.state,
      required this.created,
      required this.completed});
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
    };
  }

  MealPlan copyWith(
          {int? id,
          int? parentPlanId,
          String? title,
          String? notes,
          MealPlanState? state,
          DateTime? created,
          DateTime? completed}) =>
      MealPlan(
        id: id ?? this.id,
        parentPlanId: parentPlanId ?? this.parentPlanId,
        title: title ?? this.title,
        notes: notes ?? this.notes,
        state: state ?? this.state,
        created: created ?? this.created,
        completed: completed ?? this.completed,
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
          ..write('completed: $completed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, parentPlanId, title, notes, state, created, completed);
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
          other.completed == this.completed);
}

class MealPlansCompanion extends UpdateCompanion<MealPlan> {
  final Value<int> id;
  final Value<int> parentPlanId;
  final Value<String> title;
  final Value<String> notes;
  final Value<MealPlanState> state;
  final Value<DateTime> created;
  final Value<DateTime> completed;
  const MealPlansCompanion({
    this.id = const Value.absent(),
    this.parentPlanId = const Value.absent(),
    this.title = const Value.absent(),
    this.notes = const Value.absent(),
    this.state = const Value.absent(),
    this.created = const Value.absent(),
    this.completed = const Value.absent(),
  });
  MealPlansCompanion.insert({
    this.id = const Value.absent(),
    required int parentPlanId,
    required String title,
    required String notes,
    required MealPlanState state,
    required DateTime created,
    required DateTime completed,
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
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (parentPlanId != null) 'parentPlanId': parentPlanId,
      if (title != null) 'title': title,
      if (notes != null) 'notes': notes,
      if (state != null) 'state': state,
      if (created != null) 'created': created,
      if (completed != null) 'completed': completed,
    });
  }

  MealPlansCompanion copyWith(
      {Value<int>? id,
      Value<int>? parentPlanId,
      Value<String>? title,
      Value<String>? notes,
      Value<MealPlanState>? state,
      Value<DateTime>? created,
      Value<DateTime>? completed}) {
    return MealPlansCompanion(
      id: id ?? this.id,
      parentPlanId: parentPlanId ?? this.parentPlanId,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      state: state ?? this.state,
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
          ..write('completed: $completed')
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
  late final $DatasetTable dataset = $DatasetTable(this);
  late final $ExercisesTable exercises = $ExercisesTable(this);
  late final $SetsTable sets = $SetsTable(this);
  late final $MeasurementsTable measurements = $MeasurementsTable(this);
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
  late final Index indexExercisesIdExerciseDC = Index(
      'index_exercises_idExerciseDC',
      'CREATE INDEX index_exercises_idExerciseDC ON exercises (idExerciseDC)');
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
        dataset,
        exercises,
        sets,
        measurements,
        products,
        recipes,
        recipeIngredients,
        mealPlans,
        meals,
        mealItems,
        indexExercisesWorkoutId,
        indexExercisesWorkoutIdPosition,
        indexExercisesIdExerciseDC,
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

typedef $$DatasetTableInsertCompanionBuilder = DatasetCompanion Function({
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
typedef $$DatasetTableUpdateCompanionBuilder = DatasetCompanion Function({
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

class $$DatasetTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DatasetTable,
    ExerciseDC,
    $$DatasetTableFilterComposer,
    $$DatasetTableOrderingComposer,
    $$DatasetTableProcessedTableManager,
    $$DatasetTableInsertCompanionBuilder,
    $$DatasetTableUpdateCompanionBuilder> {
  $$DatasetTableTableManager(_$AppDatabase db, $DatasetTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$DatasetTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$DatasetTableOrderingComposer(ComposerState(db, table)),
          getChildManagerBuilder: (p) => $$DatasetTableProcessedTableManager(p),
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
              DatasetCompanion(
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
              DatasetCompanion.insert(
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

class $$DatasetTableProcessedTableManager extends ProcessedTableManager<
    _$AppDatabase,
    $DatasetTable,
    ExerciseDC,
    $$DatasetTableFilterComposer,
    $$DatasetTableOrderingComposer,
    $$DatasetTableProcessedTableManager,
    $$DatasetTableInsertCompanionBuilder,
    $$DatasetTableUpdateCompanionBuilder> {
  $$DatasetTableProcessedTableManager(super.$state);
}

class $$DatasetTableFilterComposer
    extends FilterComposer<_$AppDatabase, $DatasetTable> {
  $$DatasetTableFilterComposer(super.$state);
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

class $$DatasetTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $DatasetTable> {
  $$DatasetTableOrderingComposer(super.$state);
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
  required String idExerciseDC,
  required String notes,
  required SetMode setMode,
  required int restTime,
  Value<int> position,
  Value<int?> supersetId,
  required int workoutId,
});
typedef $$ExercisesTableUpdateCompanionBuilder = ExercisesCompanion Function({
  Value<int> id,
  Value<String> idExerciseDC,
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
            Value<String> idExerciseDC = const Value.absent(),
            Value<String> notes = const Value.absent(),
            Value<SetMode> setMode = const Value.absent(),
            Value<int> restTime = const Value.absent(),
            Value<int> position = const Value.absent(),
            Value<int?> supersetId = const Value.absent(),
            Value<int> workoutId = const Value.absent(),
          }) =>
              ExercisesCompanion(
            id: id,
            idExerciseDC: idExerciseDC,
            notes: notes,
            setMode: setMode,
            restTime: restTime,
            position: position,
            supersetId: supersetId,
            workoutId: workoutId,
          ),
          getInsertCompanionBuilder: ({
            Value<int> id = const Value.absent(),
            required String idExerciseDC,
            required String notes,
            required SetMode setMode,
            required int restTime,
            Value<int> position = const Value.absent(),
            Value<int?> supersetId = const Value.absent(),
            required int workoutId,
          }) =>
              ExercisesCompanion.insert(
            id: id,
            idExerciseDC: idExerciseDC,
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

  ColumnFilters<String> get idExerciseDC => $state.composableBuilder(
      column: $state.table.idExerciseDC,
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

  ColumnOrderings<String> get idExerciseDC => $state.composableBuilder(
      column: $state.table.idExerciseDC,
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
  Value<int?> intensityScale,
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
  Value<int?> intensityScale,
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
            Value<int?> intensityScale = const Value.absent(),
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
            intensityScale: intensityScale,
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
            Value<int?> intensityScale = const Value.absent(),
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
            intensityScale: intensityScale,
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

  ColumnFilters<int> get intensityScale => $state.composableBuilder(
      column: $state.table.intensityScale,
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

  ColumnOrderings<int> get intensityScale => $state.composableBuilder(
      column: $state.table.intensityScale,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get exerciseId => $state.composableBuilder(
      column: $state.table.exerciseId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$MeasurementsTableInsertCompanionBuilder = MeasurementsCompanion
    Function({
  Value<int> id,
  required double bodyWeight,
  required int bodyFatPercentage,
  required int muscleMassPercentage,
  required DateTime date,
  required String notes,
});
typedef $$MeasurementsTableUpdateCompanionBuilder = MeasurementsCompanion
    Function({
  Value<int> id,
  Value<double> bodyWeight,
  Value<int> bodyFatPercentage,
  Value<int> muscleMassPercentage,
  Value<DateTime> date,
  Value<String> notes,
});

class $$MeasurementsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MeasurementsTable,
    Measurement,
    $$MeasurementsTableFilterComposer,
    $$MeasurementsTableOrderingComposer,
    $$MeasurementsTableProcessedTableManager,
    $$MeasurementsTableInsertCompanionBuilder,
    $$MeasurementsTableUpdateCompanionBuilder> {
  $$MeasurementsTableTableManager(_$AppDatabase db, $MeasurementsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$MeasurementsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$MeasurementsTableOrderingComposer(ComposerState(db, table)),
          getChildManagerBuilder: (p) =>
              $$MeasurementsTableProcessedTableManager(p),
          getUpdateCompanionBuilder: ({
            Value<int> id = const Value.absent(),
            Value<double> bodyWeight = const Value.absent(),
            Value<int> bodyFatPercentage = const Value.absent(),
            Value<int> muscleMassPercentage = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<String> notes = const Value.absent(),
          }) =>
              MeasurementsCompanion(
            id: id,
            bodyWeight: bodyWeight,
            bodyFatPercentage: bodyFatPercentage,
            muscleMassPercentage: muscleMassPercentage,
            date: date,
            notes: notes,
          ),
          getInsertCompanionBuilder: ({
            Value<int> id = const Value.absent(),
            required double bodyWeight,
            required int bodyFatPercentage,
            required int muscleMassPercentage,
            required DateTime date,
            required String notes,
          }) =>
              MeasurementsCompanion.insert(
            id: id,
            bodyWeight: bodyWeight,
            bodyFatPercentage: bodyFatPercentage,
            muscleMassPercentage: muscleMassPercentage,
            date: date,
            notes: notes,
          ),
        ));
}

class $$MeasurementsTableProcessedTableManager extends ProcessedTableManager<
    _$AppDatabase,
    $MeasurementsTable,
    Measurement,
    $$MeasurementsTableFilterComposer,
    $$MeasurementsTableOrderingComposer,
    $$MeasurementsTableProcessedTableManager,
    $$MeasurementsTableInsertCompanionBuilder,
    $$MeasurementsTableUpdateCompanionBuilder> {
  $$MeasurementsTableProcessedTableManager(super.$state);
}

class $$MeasurementsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $MeasurementsTable> {
  $$MeasurementsTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get bodyWeight => $state.composableBuilder(
      column: $state.table.bodyWeight,
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

class $$MeasurementsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $MeasurementsTable> {
  $$MeasurementsTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get bodyWeight => $state.composableBuilder(
      column: $state.table.bodyWeight,
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
  required double cost,
  required int quantity,
  required String units,
  required double ediblePercent,
  required double edibleQtyPerUnit,
  required double proteins,
  required double carbs,
  required double fats,
  required bool isSupplement,
  Value<bool> isPortable,
});
typedef $$ProductsTableUpdateCompanionBuilder = ProductsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<double> weight,
  Value<double> cost,
  Value<int> quantity,
  Value<String> units,
  Value<double> ediblePercent,
  Value<double> edibleQtyPerUnit,
  Value<double> proteins,
  Value<double> carbs,
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
            Value<double> cost = const Value.absent(),
            Value<int> quantity = const Value.absent(),
            Value<String> units = const Value.absent(),
            Value<double> ediblePercent = const Value.absent(),
            Value<double> edibleQtyPerUnit = const Value.absent(),
            Value<double> proteins = const Value.absent(),
            Value<double> carbs = const Value.absent(),
            Value<double> fats = const Value.absent(),
            Value<bool> isSupplement = const Value.absent(),
            Value<bool> isPortable = const Value.absent(),
          }) =>
              ProductsCompanion(
            id: id,
            name: name,
            weight: weight,
            cost: cost,
            quantity: quantity,
            units: units,
            ediblePercent: ediblePercent,
            edibleQtyPerUnit: edibleQtyPerUnit,
            proteins: proteins,
            carbs: carbs,
            fats: fats,
            isSupplement: isSupplement,
            isPortable: isPortable,
          ),
          getInsertCompanionBuilder: ({
            Value<int> id = const Value.absent(),
            required String name,
            required double weight,
            required double cost,
            required int quantity,
            required String units,
            required double ediblePercent,
            required double edibleQtyPerUnit,
            required double proteins,
            required double carbs,
            required double fats,
            required bool isSupplement,
            Value<bool> isPortable = const Value.absent(),
          }) =>
              ProductsCompanion.insert(
            id: id,
            name: name,
            weight: weight,
            cost: cost,
            quantity: quantity,
            units: units,
            ediblePercent: ediblePercent,
            edibleQtyPerUnit: edibleQtyPerUnit,
            proteins: proteins,
            carbs: carbs,
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

  ColumnFilters<double> get cost => $state.composableBuilder(
      column: $state.table.cost,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get quantity => $state.composableBuilder(
      column: $state.table.quantity,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get units => $state.composableBuilder(
      column: $state.table.units,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get ediblePercent => $state.composableBuilder(
      column: $state.table.ediblePercent,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get edibleQtyPerUnit => $state.composableBuilder(
      column: $state.table.edibleQtyPerUnit,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get proteins => $state.composableBuilder(
      column: $state.table.proteins,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get carbs => $state.composableBuilder(
      column: $state.table.carbs,
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

  ColumnOrderings<double> get cost => $state.composableBuilder(
      column: $state.table.cost,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get quantity => $state.composableBuilder(
      column: $state.table.quantity,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get units => $state.composableBuilder(
      column: $state.table.units,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get ediblePercent => $state.composableBuilder(
      column: $state.table.ediblePercent,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get edibleQtyPerUnit => $state.composableBuilder(
      column: $state.table.edibleQtyPerUnit,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get proteins => $state.composableBuilder(
      column: $state.table.proteins,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get carbs => $state.composableBuilder(
      column: $state.table.carbs,
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
});
typedef $$RecipeIngredientsTableUpdateCompanionBuilder
    = RecipeIngredientsCompanion Function({
  Value<int> id,
  Value<int> recipeId,
  Value<int> productId,
  Value<double> amount,
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
          }) =>
              RecipeIngredientsCompanion(
            id: id,
            recipeId: recipeId,
            productId: productId,
            amount: amount,
          ),
          getInsertCompanionBuilder: ({
            Value<int> id = const Value.absent(),
            required int recipeId,
            required int productId,
            required double amount,
          }) =>
              RecipeIngredientsCompanion.insert(
            id: id,
            recipeId: recipeId,
            productId: productId,
            amount: amount,
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
}

typedef $$MealPlansTableInsertCompanionBuilder = MealPlansCompanion Function({
  Value<int> id,
  required int parentPlanId,
  required String title,
  required String notes,
  required MealPlanState state,
  required DateTime created,
  required DateTime completed,
});
typedef $$MealPlansTableUpdateCompanionBuilder = MealPlansCompanion Function({
  Value<int> id,
  Value<int> parentPlanId,
  Value<String> title,
  Value<String> notes,
  Value<MealPlanState> state,
  Value<DateTime> created,
  Value<DateTime> completed,
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
          }) =>
              MealPlansCompanion(
            id: id,
            parentPlanId: parentPlanId,
            title: title,
            notes: notes,
            state: state,
            created: created,
            completed: completed,
          ),
          getInsertCompanionBuilder: ({
            Value<int> id = const Value.absent(),
            required int parentPlanId,
            required String title,
            required String notes,
            required MealPlanState state,
            required DateTime created,
            required DateTime completed,
          }) =>
              MealPlansCompanion.insert(
            id: id,
            parentPlanId: parentPlanId,
            title: title,
            notes: notes,
            state: state,
            created: created,
            completed: completed,
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
  $$DatasetTableTableManager get dataset =>
      $$DatasetTableTableManager(_db, _db.dataset);
  $$ExercisesTableTableManager get exercises =>
      $$ExercisesTableTableManager(_db, _db.exercises);
  $$SetsTableTableManager get sets => $$SetsTableTableManager(_db, _db.sets);
  $$MeasurementsTableTableManager get measurements =>
      $$MeasurementsTableTableManager(_db, _db.measurements);
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
