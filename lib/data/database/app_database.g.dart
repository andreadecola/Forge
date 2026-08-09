// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $AppSettingsTableTable extends AppSettingsTable
    with TableInfo<$AppSettingsTableTable, AppSettingsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSettingsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSettingsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSettingsTableData(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $AppSettingsTableTable createAlias(String alias) {
    return $AppSettingsTableTable(attachedDatabase, alias);
  }
}

class AppSettingsTableData extends DataClass
    implements Insertable<AppSettingsTableData> {
  final String key;
  final String value;
  const AppSettingsTableData({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppSettingsTableCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsTableCompanion(key: Value(key), value: Value(value));
  }

  factory AppSettingsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSettingsTableData(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppSettingsTableData copyWith({String? key, String? value}) =>
      AppSettingsTableData(key: key ?? this.key, value: value ?? this.value);
  AppSettingsTableData copyWithCompanion(AppSettingsTableCompanion data) {
    return AppSettingsTableData(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsTableData(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSettingsTableData &&
          other.key == this.key &&
          other.value == this.value);
}

class AppSettingsTableCompanion extends UpdateCompanion<AppSettingsTableData> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppSettingsTableCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsTableCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<AppSettingsTableData> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsTableCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return AppSettingsTableCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsTableCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserProfilesTableTable extends UserProfilesTable
    with TableInfo<$UserProfilesTableTable, UserProfilesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserProfilesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _birthDateMeta = const VerificationMeta(
    'birthDate',
  );
  @override
  late final GeneratedColumn<DateTime> birthDate = GeneratedColumn<DateTime>(
    'birth_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _biologicalSexForFormulaMeta =
      const VerificationMeta('biologicalSexForFormula');
  @override
  late final GeneratedColumn<String> biologicalSexForFormula =
      GeneratedColumn<String>(
        'biological_sex_for_formula',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _heightCmMeta = const VerificationMeta(
    'heightCm',
  );
  @override
  late final GeneratedColumn<double> heightCm = GeneratedColumn<double>(
    'height_cm',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _initialWeightKgMeta = const VerificationMeta(
    'initialWeightKg',
  );
  @override
  late final GeneratedColumn<double> initialWeightKg = GeneratedColumn<double>(
    'initial_weight_kg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetWeightKgMeta = const VerificationMeta(
    'targetWeightKg',
  );
  @override
  late final GeneratedColumn<double> targetWeightKg = GeneratedColumn<double>(
    'target_weight_kg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _preferredWalkMinutesMeta =
      const VerificationMeta('preferredWalkMinutes');
  @override
  late final GeneratedColumn<int> preferredWalkMinutes = GeneratedColumn<int>(
    'preferred_walk_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _equipmentBudgetLimitMeta =
      const VerificationMeta('equipmentBudgetLimit');
  @override
  late final GeneratedColumn<double> equipmentBudgetLimit =
      GeneratedColumn<double>(
        'equipment_budget_limit',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _activityLevelMeta = const VerificationMeta(
    'activityLevel',
  );
  @override
  late final GeneratedColumn<String> activityLevel = GeneratedColumn<String>(
    'activity_level',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    birthDate,
    biologicalSexForFormula,
    heightCm,
    initialWeightKg,
    targetWeightKg,
    preferredWalkMinutes,
    equipmentBudgetLimit,
    startDate,
    activityLevel,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_profiles_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserProfilesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('birth_date')) {
      context.handle(
        _birthDateMeta,
        birthDate.isAcceptableOrUnknown(data['birth_date']!, _birthDateMeta),
      );
    } else if (isInserting) {
      context.missing(_birthDateMeta);
    }
    if (data.containsKey('biological_sex_for_formula')) {
      context.handle(
        _biologicalSexForFormulaMeta,
        biologicalSexForFormula.isAcceptableOrUnknown(
          data['biological_sex_for_formula']!,
          _biologicalSexForFormulaMeta,
        ),
      );
    }
    if (data.containsKey('height_cm')) {
      context.handle(
        _heightCmMeta,
        heightCm.isAcceptableOrUnknown(data['height_cm']!, _heightCmMeta),
      );
    } else if (isInserting) {
      context.missing(_heightCmMeta);
    }
    if (data.containsKey('initial_weight_kg')) {
      context.handle(
        _initialWeightKgMeta,
        initialWeightKg.isAcceptableOrUnknown(
          data['initial_weight_kg']!,
          _initialWeightKgMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_initialWeightKgMeta);
    }
    if (data.containsKey('target_weight_kg')) {
      context.handle(
        _targetWeightKgMeta,
        targetWeightKg.isAcceptableOrUnknown(
          data['target_weight_kg']!,
          _targetWeightKgMeta,
        ),
      );
    }
    if (data.containsKey('preferred_walk_minutes')) {
      context.handle(
        _preferredWalkMinutesMeta,
        preferredWalkMinutes.isAcceptableOrUnknown(
          data['preferred_walk_minutes']!,
          _preferredWalkMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_preferredWalkMinutesMeta);
    }
    if (data.containsKey('equipment_budget_limit')) {
      context.handle(
        _equipmentBudgetLimitMeta,
        equipmentBudgetLimit.isAcceptableOrUnknown(
          data['equipment_budget_limit']!,
          _equipmentBudgetLimitMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_equipmentBudgetLimitMeta);
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('activity_level')) {
      context.handle(
        _activityLevelMeta,
        activityLevel.isAcceptableOrUnknown(
          data['activity_level']!,
          _activityLevelMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserProfilesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserProfilesTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      birthDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}birth_date'],
      )!,
      biologicalSexForFormula: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}biological_sex_for_formula'],
      ),
      heightCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}height_cm'],
      )!,
      initialWeightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}initial_weight_kg'],
      )!,
      targetWeightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}target_weight_kg'],
      ),
      preferredWalkMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}preferred_walk_minutes'],
      )!,
      equipmentBudgetLimit: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}equipment_budget_limit'],
      )!,
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      )!,
      activityLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}activity_level'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $UserProfilesTableTable createAlias(String alias) {
    return $UserProfilesTableTable(attachedDatabase, alias);
  }
}

class UserProfilesTableData extends DataClass
    implements Insertable<UserProfilesTableData> {
  final int id;
  final String name;
  final DateTime birthDate;

  /// Nullable: assente quando l'utente sceglie "preferisco non specificarlo".
  /// In tal caso BMR/TDEE non vengono stimati.
  final String? biologicalSexForFormula;
  final double heightCm;
  final double initialWeightKg;
  final double? targetWeightKg;
  final int preferredWalkMinutes;
  final double equipmentBudgetLimit;
  final DateTime startDate;

  /// Estensione rispetto allo schema documentato in 03_Database_Design.md:
  /// necessaria per stimare il TDEE (vedi 09_Roadmap M2 / 12_Body_Metrics).
  final String? activityLevel;
  final DateTime createdAt;
  final DateTime updatedAt;
  const UserProfilesTableData({
    required this.id,
    required this.name,
    required this.birthDate,
    this.biologicalSexForFormula,
    required this.heightCm,
    required this.initialWeightKg,
    this.targetWeightKg,
    required this.preferredWalkMinutes,
    required this.equipmentBudgetLimit,
    required this.startDate,
    this.activityLevel,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['birth_date'] = Variable<DateTime>(birthDate);
    if (!nullToAbsent || biologicalSexForFormula != null) {
      map['biological_sex_for_formula'] = Variable<String>(
        biologicalSexForFormula,
      );
    }
    map['height_cm'] = Variable<double>(heightCm);
    map['initial_weight_kg'] = Variable<double>(initialWeightKg);
    if (!nullToAbsent || targetWeightKg != null) {
      map['target_weight_kg'] = Variable<double>(targetWeightKg);
    }
    map['preferred_walk_minutes'] = Variable<int>(preferredWalkMinutes);
    map['equipment_budget_limit'] = Variable<double>(equipmentBudgetLimit);
    map['start_date'] = Variable<DateTime>(startDate);
    if (!nullToAbsent || activityLevel != null) {
      map['activity_level'] = Variable<String>(activityLevel);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  UserProfilesTableCompanion toCompanion(bool nullToAbsent) {
    return UserProfilesTableCompanion(
      id: Value(id),
      name: Value(name),
      birthDate: Value(birthDate),
      biologicalSexForFormula: biologicalSexForFormula == null && nullToAbsent
          ? const Value.absent()
          : Value(biologicalSexForFormula),
      heightCm: Value(heightCm),
      initialWeightKg: Value(initialWeightKg),
      targetWeightKg: targetWeightKg == null && nullToAbsent
          ? const Value.absent()
          : Value(targetWeightKg),
      preferredWalkMinutes: Value(preferredWalkMinutes),
      equipmentBudgetLimit: Value(equipmentBudgetLimit),
      startDate: Value(startDate),
      activityLevel: activityLevel == null && nullToAbsent
          ? const Value.absent()
          : Value(activityLevel),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory UserProfilesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserProfilesTableData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      birthDate: serializer.fromJson<DateTime>(json['birthDate']),
      biologicalSexForFormula: serializer.fromJson<String?>(
        json['biologicalSexForFormula'],
      ),
      heightCm: serializer.fromJson<double>(json['heightCm']),
      initialWeightKg: serializer.fromJson<double>(json['initialWeightKg']),
      targetWeightKg: serializer.fromJson<double?>(json['targetWeightKg']),
      preferredWalkMinutes: serializer.fromJson<int>(
        json['preferredWalkMinutes'],
      ),
      equipmentBudgetLimit: serializer.fromJson<double>(
        json['equipmentBudgetLimit'],
      ),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      activityLevel: serializer.fromJson<String?>(json['activityLevel']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'birthDate': serializer.toJson<DateTime>(birthDate),
      'biologicalSexForFormula': serializer.toJson<String?>(
        biologicalSexForFormula,
      ),
      'heightCm': serializer.toJson<double>(heightCm),
      'initialWeightKg': serializer.toJson<double>(initialWeightKg),
      'targetWeightKg': serializer.toJson<double?>(targetWeightKg),
      'preferredWalkMinutes': serializer.toJson<int>(preferredWalkMinutes),
      'equipmentBudgetLimit': serializer.toJson<double>(equipmentBudgetLimit),
      'startDate': serializer.toJson<DateTime>(startDate),
      'activityLevel': serializer.toJson<String?>(activityLevel),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  UserProfilesTableData copyWith({
    int? id,
    String? name,
    DateTime? birthDate,
    Value<String?> biologicalSexForFormula = const Value.absent(),
    double? heightCm,
    double? initialWeightKg,
    Value<double?> targetWeightKg = const Value.absent(),
    int? preferredWalkMinutes,
    double? equipmentBudgetLimit,
    DateTime? startDate,
    Value<String?> activityLevel = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => UserProfilesTableData(
    id: id ?? this.id,
    name: name ?? this.name,
    birthDate: birthDate ?? this.birthDate,
    biologicalSexForFormula: biologicalSexForFormula.present
        ? biologicalSexForFormula.value
        : this.biologicalSexForFormula,
    heightCm: heightCm ?? this.heightCm,
    initialWeightKg: initialWeightKg ?? this.initialWeightKg,
    targetWeightKg: targetWeightKg.present
        ? targetWeightKg.value
        : this.targetWeightKg,
    preferredWalkMinutes: preferredWalkMinutes ?? this.preferredWalkMinutes,
    equipmentBudgetLimit: equipmentBudgetLimit ?? this.equipmentBudgetLimit,
    startDate: startDate ?? this.startDate,
    activityLevel: activityLevel.present
        ? activityLevel.value
        : this.activityLevel,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  UserProfilesTableData copyWithCompanion(UserProfilesTableCompanion data) {
    return UserProfilesTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      birthDate: data.birthDate.present ? data.birthDate.value : this.birthDate,
      biologicalSexForFormula: data.biologicalSexForFormula.present
          ? data.biologicalSexForFormula.value
          : this.biologicalSexForFormula,
      heightCm: data.heightCm.present ? data.heightCm.value : this.heightCm,
      initialWeightKg: data.initialWeightKg.present
          ? data.initialWeightKg.value
          : this.initialWeightKg,
      targetWeightKg: data.targetWeightKg.present
          ? data.targetWeightKg.value
          : this.targetWeightKg,
      preferredWalkMinutes: data.preferredWalkMinutes.present
          ? data.preferredWalkMinutes.value
          : this.preferredWalkMinutes,
      equipmentBudgetLimit: data.equipmentBudgetLimit.present
          ? data.equipmentBudgetLimit.value
          : this.equipmentBudgetLimit,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      activityLevel: data.activityLevel.present
          ? data.activityLevel.value
          : this.activityLevel,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserProfilesTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('birthDate: $birthDate, ')
          ..write('biologicalSexForFormula: $biologicalSexForFormula, ')
          ..write('heightCm: $heightCm, ')
          ..write('initialWeightKg: $initialWeightKg, ')
          ..write('targetWeightKg: $targetWeightKg, ')
          ..write('preferredWalkMinutes: $preferredWalkMinutes, ')
          ..write('equipmentBudgetLimit: $equipmentBudgetLimit, ')
          ..write('startDate: $startDate, ')
          ..write('activityLevel: $activityLevel, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    birthDate,
    biologicalSexForFormula,
    heightCm,
    initialWeightKg,
    targetWeightKg,
    preferredWalkMinutes,
    equipmentBudgetLimit,
    startDate,
    activityLevel,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserProfilesTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.birthDate == this.birthDate &&
          other.biologicalSexForFormula == this.biologicalSexForFormula &&
          other.heightCm == this.heightCm &&
          other.initialWeightKg == this.initialWeightKg &&
          other.targetWeightKg == this.targetWeightKg &&
          other.preferredWalkMinutes == this.preferredWalkMinutes &&
          other.equipmentBudgetLimit == this.equipmentBudgetLimit &&
          other.startDate == this.startDate &&
          other.activityLevel == this.activityLevel &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class UserProfilesTableCompanion
    extends UpdateCompanion<UserProfilesTableData> {
  final Value<int> id;
  final Value<String> name;
  final Value<DateTime> birthDate;
  final Value<String?> biologicalSexForFormula;
  final Value<double> heightCm;
  final Value<double> initialWeightKg;
  final Value<double?> targetWeightKg;
  final Value<int> preferredWalkMinutes;
  final Value<double> equipmentBudgetLimit;
  final Value<DateTime> startDate;
  final Value<String?> activityLevel;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const UserProfilesTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.birthDate = const Value.absent(),
    this.biologicalSexForFormula = const Value.absent(),
    this.heightCm = const Value.absent(),
    this.initialWeightKg = const Value.absent(),
    this.targetWeightKg = const Value.absent(),
    this.preferredWalkMinutes = const Value.absent(),
    this.equipmentBudgetLimit = const Value.absent(),
    this.startDate = const Value.absent(),
    this.activityLevel = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  UserProfilesTableCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required DateTime birthDate,
    this.biologicalSexForFormula = const Value.absent(),
    required double heightCm,
    required double initialWeightKg,
    this.targetWeightKg = const Value.absent(),
    required int preferredWalkMinutes,
    required double equipmentBudgetLimit,
    required DateTime startDate,
    this.activityLevel = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : name = Value(name),
       birthDate = Value(birthDate),
       heightCm = Value(heightCm),
       initialWeightKg = Value(initialWeightKg),
       preferredWalkMinutes = Value(preferredWalkMinutes),
       equipmentBudgetLimit = Value(equipmentBudgetLimit),
       startDate = Value(startDate),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<UserProfilesTableData> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<DateTime>? birthDate,
    Expression<String>? biologicalSexForFormula,
    Expression<double>? heightCm,
    Expression<double>? initialWeightKg,
    Expression<double>? targetWeightKg,
    Expression<int>? preferredWalkMinutes,
    Expression<double>? equipmentBudgetLimit,
    Expression<DateTime>? startDate,
    Expression<String>? activityLevel,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (birthDate != null) 'birth_date': birthDate,
      if (biologicalSexForFormula != null)
        'biological_sex_for_formula': biologicalSexForFormula,
      if (heightCm != null) 'height_cm': heightCm,
      if (initialWeightKg != null) 'initial_weight_kg': initialWeightKg,
      if (targetWeightKg != null) 'target_weight_kg': targetWeightKg,
      if (preferredWalkMinutes != null)
        'preferred_walk_minutes': preferredWalkMinutes,
      if (equipmentBudgetLimit != null)
        'equipment_budget_limit': equipmentBudgetLimit,
      if (startDate != null) 'start_date': startDate,
      if (activityLevel != null) 'activity_level': activityLevel,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  UserProfilesTableCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<DateTime>? birthDate,
    Value<String?>? biologicalSexForFormula,
    Value<double>? heightCm,
    Value<double>? initialWeightKg,
    Value<double?>? targetWeightKg,
    Value<int>? preferredWalkMinutes,
    Value<double>? equipmentBudgetLimit,
    Value<DateTime>? startDate,
    Value<String?>? activityLevel,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return UserProfilesTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      biologicalSexForFormula:
          biologicalSexForFormula ?? this.biologicalSexForFormula,
      heightCm: heightCm ?? this.heightCm,
      initialWeightKg: initialWeightKg ?? this.initialWeightKg,
      targetWeightKg: targetWeightKg ?? this.targetWeightKg,
      preferredWalkMinutes: preferredWalkMinutes ?? this.preferredWalkMinutes,
      equipmentBudgetLimit: equipmentBudgetLimit ?? this.equipmentBudgetLimit,
      startDate: startDate ?? this.startDate,
      activityLevel: activityLevel ?? this.activityLevel,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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
    if (birthDate.present) {
      map['birth_date'] = Variable<DateTime>(birthDate.value);
    }
    if (biologicalSexForFormula.present) {
      map['biological_sex_for_formula'] = Variable<String>(
        biologicalSexForFormula.value,
      );
    }
    if (heightCm.present) {
      map['height_cm'] = Variable<double>(heightCm.value);
    }
    if (initialWeightKg.present) {
      map['initial_weight_kg'] = Variable<double>(initialWeightKg.value);
    }
    if (targetWeightKg.present) {
      map['target_weight_kg'] = Variable<double>(targetWeightKg.value);
    }
    if (preferredWalkMinutes.present) {
      map['preferred_walk_minutes'] = Variable<int>(preferredWalkMinutes.value);
    }
    if (equipmentBudgetLimit.present) {
      map['equipment_budget_limit'] = Variable<double>(
        equipmentBudgetLimit.value,
      );
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (activityLevel.present) {
      map['activity_level'] = Variable<String>(activityLevel.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserProfilesTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('birthDate: $birthDate, ')
          ..write('biologicalSexForFormula: $biologicalSexForFormula, ')
          ..write('heightCm: $heightCm, ')
          ..write('initialWeightKg: $initialWeightKg, ')
          ..write('targetWeightKg: $targetWeightKg, ')
          ..write('preferredWalkMinutes: $preferredWalkMinutes, ')
          ..write('equipmentBudgetLimit: $equipmentBudgetLimit, ')
          ..write('startDate: $startDate, ')
          ..write('activityLevel: $activityLevel, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $BodyMeasurementsTableTable extends BodyMeasurementsTable
    with TableInfo<$BodyMeasurementsTableTable, BodyMeasurementsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BodyMeasurementsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<int> profileId = GeneratedColumn<int>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES user_profiles_table (id)',
    ),
  );
  static const VerificationMeta _measuredAtMeta = const VerificationMeta(
    'measuredAt',
  );
  @override
  late final GeneratedColumn<DateTime> measuredAt = GeneratedColumn<DateTime>(
    'measured_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weightKgMeta = const VerificationMeta(
    'weightKg',
  );
  @override
  late final GeneratedColumn<double> weightKg = GeneratedColumn<double>(
    'weight_kg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _neckCmMeta = const VerificationMeta('neckCm');
  @override
  late final GeneratedColumn<double> neckCm = GeneratedColumn<double>(
    'neck_cm',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _chestCmMeta = const VerificationMeta(
    'chestCm',
  );
  @override
  late final GeneratedColumn<double> chestCm = GeneratedColumn<double>(
    'chest_cm',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _waistCmMeta = const VerificationMeta(
    'waistCm',
  );
  @override
  late final GeneratedColumn<double> waistCm = GeneratedColumn<double>(
    'waist_cm',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _abdomenCmMeta = const VerificationMeta(
    'abdomenCm',
  );
  @override
  late final GeneratedColumn<double> abdomenCm = GeneratedColumn<double>(
    'abdomen_cm',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hipsCmMeta = const VerificationMeta('hipsCm');
  @override
  late final GeneratedColumn<double> hipsCm = GeneratedColumn<double>(
    'hips_cm',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _leftArmCmMeta = const VerificationMeta(
    'leftArmCm',
  );
  @override
  late final GeneratedColumn<double> leftArmCm = GeneratedColumn<double>(
    'left_arm_cm',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rightArmCmMeta = const VerificationMeta(
    'rightArmCm',
  );
  @override
  late final GeneratedColumn<double> rightArmCm = GeneratedColumn<double>(
    'right_arm_cm',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _leftThighCmMeta = const VerificationMeta(
    'leftThighCm',
  );
  @override
  late final GeneratedColumn<double> leftThighCm = GeneratedColumn<double>(
    'left_thigh_cm',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rightThighCmMeta = const VerificationMeta(
    'rightThighCm',
  );
  @override
  late final GeneratedColumn<double> rightThighCm = GeneratedColumn<double>(
    'right_thigh_cm',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _leftCalfCmMeta = const VerificationMeta(
    'leftCalfCm',
  );
  @override
  late final GeneratedColumn<double> leftCalfCm = GeneratedColumn<double>(
    'left_calf_cm',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rightCalfCmMeta = const VerificationMeta(
    'rightCalfCm',
  );
  @override
  late final GeneratedColumn<double> rightCalfCm = GeneratedColumn<double>(
    'right_calf_cm',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    profileId,
    measuredAt,
    weightKg,
    neckCm,
    chestCm,
    waistCm,
    abdomenCm,
    hipsCm,
    leftArmCm,
    rightArmCm,
    leftThighCm,
    rightThighCm,
    leftCalfCm,
    rightCalfCm,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'body_measurements_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<BodyMeasurementsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('measured_at')) {
      context.handle(
        _measuredAtMeta,
        measuredAt.isAcceptableOrUnknown(data['measured_at']!, _measuredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_measuredAtMeta);
    }
    if (data.containsKey('weight_kg')) {
      context.handle(
        _weightKgMeta,
        weightKg.isAcceptableOrUnknown(data['weight_kg']!, _weightKgMeta),
      );
    } else if (isInserting) {
      context.missing(_weightKgMeta);
    }
    if (data.containsKey('neck_cm')) {
      context.handle(
        _neckCmMeta,
        neckCm.isAcceptableOrUnknown(data['neck_cm']!, _neckCmMeta),
      );
    }
    if (data.containsKey('chest_cm')) {
      context.handle(
        _chestCmMeta,
        chestCm.isAcceptableOrUnknown(data['chest_cm']!, _chestCmMeta),
      );
    }
    if (data.containsKey('waist_cm')) {
      context.handle(
        _waistCmMeta,
        waistCm.isAcceptableOrUnknown(data['waist_cm']!, _waistCmMeta),
      );
    }
    if (data.containsKey('abdomen_cm')) {
      context.handle(
        _abdomenCmMeta,
        abdomenCm.isAcceptableOrUnknown(data['abdomen_cm']!, _abdomenCmMeta),
      );
    }
    if (data.containsKey('hips_cm')) {
      context.handle(
        _hipsCmMeta,
        hipsCm.isAcceptableOrUnknown(data['hips_cm']!, _hipsCmMeta),
      );
    }
    if (data.containsKey('left_arm_cm')) {
      context.handle(
        _leftArmCmMeta,
        leftArmCm.isAcceptableOrUnknown(data['left_arm_cm']!, _leftArmCmMeta),
      );
    }
    if (data.containsKey('right_arm_cm')) {
      context.handle(
        _rightArmCmMeta,
        rightArmCm.isAcceptableOrUnknown(
          data['right_arm_cm']!,
          _rightArmCmMeta,
        ),
      );
    }
    if (data.containsKey('left_thigh_cm')) {
      context.handle(
        _leftThighCmMeta,
        leftThighCm.isAcceptableOrUnknown(
          data['left_thigh_cm']!,
          _leftThighCmMeta,
        ),
      );
    }
    if (data.containsKey('right_thigh_cm')) {
      context.handle(
        _rightThighCmMeta,
        rightThighCm.isAcceptableOrUnknown(
          data['right_thigh_cm']!,
          _rightThighCmMeta,
        ),
      );
    }
    if (data.containsKey('left_calf_cm')) {
      context.handle(
        _leftCalfCmMeta,
        leftCalfCm.isAcceptableOrUnknown(
          data['left_calf_cm']!,
          _leftCalfCmMeta,
        ),
      );
    }
    if (data.containsKey('right_calf_cm')) {
      context.handle(
        _rightCalfCmMeta,
        rightCalfCm.isAcceptableOrUnknown(
          data['right_calf_cm']!,
          _rightCalfCmMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BodyMeasurementsTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BodyMeasurementsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}profile_id'],
      )!,
      measuredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}measured_at'],
      )!,
      weightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight_kg'],
      )!,
      neckCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}neck_cm'],
      ),
      chestCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}chest_cm'],
      ),
      waistCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}waist_cm'],
      ),
      abdomenCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}abdomen_cm'],
      ),
      hipsCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}hips_cm'],
      ),
      leftArmCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}left_arm_cm'],
      ),
      rightArmCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}right_arm_cm'],
      ),
      leftThighCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}left_thigh_cm'],
      ),
      rightThighCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}right_thigh_cm'],
      ),
      leftCalfCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}left_calf_cm'],
      ),
      rightCalfCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}right_calf_cm'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $BodyMeasurementsTableTable createAlias(String alias) {
    return $BodyMeasurementsTableTable(attachedDatabase, alias);
  }
}

class BodyMeasurementsTableData extends DataClass
    implements Insertable<BodyMeasurementsTableData> {
  final int id;
  final int profileId;
  final DateTime measuredAt;
  final double weightKg;
  final double? neckCm;
  final double? chestCm;
  final double? waistCm;
  final double? abdomenCm;
  final double? hipsCm;
  final double? leftArmCm;
  final double? rightArmCm;
  final double? leftThighCm;
  final double? rightThighCm;
  final double? leftCalfCm;
  final double? rightCalfCm;
  final String? notes;
  const BodyMeasurementsTableData({
    required this.id,
    required this.profileId,
    required this.measuredAt,
    required this.weightKg,
    this.neckCm,
    this.chestCm,
    this.waistCm,
    this.abdomenCm,
    this.hipsCm,
    this.leftArmCm,
    this.rightArmCm,
    this.leftThighCm,
    this.rightThighCm,
    this.leftCalfCm,
    this.rightCalfCm,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['profile_id'] = Variable<int>(profileId);
    map['measured_at'] = Variable<DateTime>(measuredAt);
    map['weight_kg'] = Variable<double>(weightKg);
    if (!nullToAbsent || neckCm != null) {
      map['neck_cm'] = Variable<double>(neckCm);
    }
    if (!nullToAbsent || chestCm != null) {
      map['chest_cm'] = Variable<double>(chestCm);
    }
    if (!nullToAbsent || waistCm != null) {
      map['waist_cm'] = Variable<double>(waistCm);
    }
    if (!nullToAbsent || abdomenCm != null) {
      map['abdomen_cm'] = Variable<double>(abdomenCm);
    }
    if (!nullToAbsent || hipsCm != null) {
      map['hips_cm'] = Variable<double>(hipsCm);
    }
    if (!nullToAbsent || leftArmCm != null) {
      map['left_arm_cm'] = Variable<double>(leftArmCm);
    }
    if (!nullToAbsent || rightArmCm != null) {
      map['right_arm_cm'] = Variable<double>(rightArmCm);
    }
    if (!nullToAbsent || leftThighCm != null) {
      map['left_thigh_cm'] = Variable<double>(leftThighCm);
    }
    if (!nullToAbsent || rightThighCm != null) {
      map['right_thigh_cm'] = Variable<double>(rightThighCm);
    }
    if (!nullToAbsent || leftCalfCm != null) {
      map['left_calf_cm'] = Variable<double>(leftCalfCm);
    }
    if (!nullToAbsent || rightCalfCm != null) {
      map['right_calf_cm'] = Variable<double>(rightCalfCm);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  BodyMeasurementsTableCompanion toCompanion(bool nullToAbsent) {
    return BodyMeasurementsTableCompanion(
      id: Value(id),
      profileId: Value(profileId),
      measuredAt: Value(measuredAt),
      weightKg: Value(weightKg),
      neckCm: neckCm == null && nullToAbsent
          ? const Value.absent()
          : Value(neckCm),
      chestCm: chestCm == null && nullToAbsent
          ? const Value.absent()
          : Value(chestCm),
      waistCm: waistCm == null && nullToAbsent
          ? const Value.absent()
          : Value(waistCm),
      abdomenCm: abdomenCm == null && nullToAbsent
          ? const Value.absent()
          : Value(abdomenCm),
      hipsCm: hipsCm == null && nullToAbsent
          ? const Value.absent()
          : Value(hipsCm),
      leftArmCm: leftArmCm == null && nullToAbsent
          ? const Value.absent()
          : Value(leftArmCm),
      rightArmCm: rightArmCm == null && nullToAbsent
          ? const Value.absent()
          : Value(rightArmCm),
      leftThighCm: leftThighCm == null && nullToAbsent
          ? const Value.absent()
          : Value(leftThighCm),
      rightThighCm: rightThighCm == null && nullToAbsent
          ? const Value.absent()
          : Value(rightThighCm),
      leftCalfCm: leftCalfCm == null && nullToAbsent
          ? const Value.absent()
          : Value(leftCalfCm),
      rightCalfCm: rightCalfCm == null && nullToAbsent
          ? const Value.absent()
          : Value(rightCalfCm),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory BodyMeasurementsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BodyMeasurementsTableData(
      id: serializer.fromJson<int>(json['id']),
      profileId: serializer.fromJson<int>(json['profileId']),
      measuredAt: serializer.fromJson<DateTime>(json['measuredAt']),
      weightKg: serializer.fromJson<double>(json['weightKg']),
      neckCm: serializer.fromJson<double?>(json['neckCm']),
      chestCm: serializer.fromJson<double?>(json['chestCm']),
      waistCm: serializer.fromJson<double?>(json['waistCm']),
      abdomenCm: serializer.fromJson<double?>(json['abdomenCm']),
      hipsCm: serializer.fromJson<double?>(json['hipsCm']),
      leftArmCm: serializer.fromJson<double?>(json['leftArmCm']),
      rightArmCm: serializer.fromJson<double?>(json['rightArmCm']),
      leftThighCm: serializer.fromJson<double?>(json['leftThighCm']),
      rightThighCm: serializer.fromJson<double?>(json['rightThighCm']),
      leftCalfCm: serializer.fromJson<double?>(json['leftCalfCm']),
      rightCalfCm: serializer.fromJson<double?>(json['rightCalfCm']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'profileId': serializer.toJson<int>(profileId),
      'measuredAt': serializer.toJson<DateTime>(measuredAt),
      'weightKg': serializer.toJson<double>(weightKg),
      'neckCm': serializer.toJson<double?>(neckCm),
      'chestCm': serializer.toJson<double?>(chestCm),
      'waistCm': serializer.toJson<double?>(waistCm),
      'abdomenCm': serializer.toJson<double?>(abdomenCm),
      'hipsCm': serializer.toJson<double?>(hipsCm),
      'leftArmCm': serializer.toJson<double?>(leftArmCm),
      'rightArmCm': serializer.toJson<double?>(rightArmCm),
      'leftThighCm': serializer.toJson<double?>(leftThighCm),
      'rightThighCm': serializer.toJson<double?>(rightThighCm),
      'leftCalfCm': serializer.toJson<double?>(leftCalfCm),
      'rightCalfCm': serializer.toJson<double?>(rightCalfCm),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  BodyMeasurementsTableData copyWith({
    int? id,
    int? profileId,
    DateTime? measuredAt,
    double? weightKg,
    Value<double?> neckCm = const Value.absent(),
    Value<double?> chestCm = const Value.absent(),
    Value<double?> waistCm = const Value.absent(),
    Value<double?> abdomenCm = const Value.absent(),
    Value<double?> hipsCm = const Value.absent(),
    Value<double?> leftArmCm = const Value.absent(),
    Value<double?> rightArmCm = const Value.absent(),
    Value<double?> leftThighCm = const Value.absent(),
    Value<double?> rightThighCm = const Value.absent(),
    Value<double?> leftCalfCm = const Value.absent(),
    Value<double?> rightCalfCm = const Value.absent(),
    Value<String?> notes = const Value.absent(),
  }) => BodyMeasurementsTableData(
    id: id ?? this.id,
    profileId: profileId ?? this.profileId,
    measuredAt: measuredAt ?? this.measuredAt,
    weightKg: weightKg ?? this.weightKg,
    neckCm: neckCm.present ? neckCm.value : this.neckCm,
    chestCm: chestCm.present ? chestCm.value : this.chestCm,
    waistCm: waistCm.present ? waistCm.value : this.waistCm,
    abdomenCm: abdomenCm.present ? abdomenCm.value : this.abdomenCm,
    hipsCm: hipsCm.present ? hipsCm.value : this.hipsCm,
    leftArmCm: leftArmCm.present ? leftArmCm.value : this.leftArmCm,
    rightArmCm: rightArmCm.present ? rightArmCm.value : this.rightArmCm,
    leftThighCm: leftThighCm.present ? leftThighCm.value : this.leftThighCm,
    rightThighCm: rightThighCm.present ? rightThighCm.value : this.rightThighCm,
    leftCalfCm: leftCalfCm.present ? leftCalfCm.value : this.leftCalfCm,
    rightCalfCm: rightCalfCm.present ? rightCalfCm.value : this.rightCalfCm,
    notes: notes.present ? notes.value : this.notes,
  );
  BodyMeasurementsTableData copyWithCompanion(
    BodyMeasurementsTableCompanion data,
  ) {
    return BodyMeasurementsTableData(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      measuredAt: data.measuredAt.present
          ? data.measuredAt.value
          : this.measuredAt,
      weightKg: data.weightKg.present ? data.weightKg.value : this.weightKg,
      neckCm: data.neckCm.present ? data.neckCm.value : this.neckCm,
      chestCm: data.chestCm.present ? data.chestCm.value : this.chestCm,
      waistCm: data.waistCm.present ? data.waistCm.value : this.waistCm,
      abdomenCm: data.abdomenCm.present ? data.abdomenCm.value : this.abdomenCm,
      hipsCm: data.hipsCm.present ? data.hipsCm.value : this.hipsCm,
      leftArmCm: data.leftArmCm.present ? data.leftArmCm.value : this.leftArmCm,
      rightArmCm: data.rightArmCm.present
          ? data.rightArmCm.value
          : this.rightArmCm,
      leftThighCm: data.leftThighCm.present
          ? data.leftThighCm.value
          : this.leftThighCm,
      rightThighCm: data.rightThighCm.present
          ? data.rightThighCm.value
          : this.rightThighCm,
      leftCalfCm: data.leftCalfCm.present
          ? data.leftCalfCm.value
          : this.leftCalfCm,
      rightCalfCm: data.rightCalfCm.present
          ? data.rightCalfCm.value
          : this.rightCalfCm,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BodyMeasurementsTableData(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('measuredAt: $measuredAt, ')
          ..write('weightKg: $weightKg, ')
          ..write('neckCm: $neckCm, ')
          ..write('chestCm: $chestCm, ')
          ..write('waistCm: $waistCm, ')
          ..write('abdomenCm: $abdomenCm, ')
          ..write('hipsCm: $hipsCm, ')
          ..write('leftArmCm: $leftArmCm, ')
          ..write('rightArmCm: $rightArmCm, ')
          ..write('leftThighCm: $leftThighCm, ')
          ..write('rightThighCm: $rightThighCm, ')
          ..write('leftCalfCm: $leftCalfCm, ')
          ..write('rightCalfCm: $rightCalfCm, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    profileId,
    measuredAt,
    weightKg,
    neckCm,
    chestCm,
    waistCm,
    abdomenCm,
    hipsCm,
    leftArmCm,
    rightArmCm,
    leftThighCm,
    rightThighCm,
    leftCalfCm,
    rightCalfCm,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BodyMeasurementsTableData &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.measuredAt == this.measuredAt &&
          other.weightKg == this.weightKg &&
          other.neckCm == this.neckCm &&
          other.chestCm == this.chestCm &&
          other.waistCm == this.waistCm &&
          other.abdomenCm == this.abdomenCm &&
          other.hipsCm == this.hipsCm &&
          other.leftArmCm == this.leftArmCm &&
          other.rightArmCm == this.rightArmCm &&
          other.leftThighCm == this.leftThighCm &&
          other.rightThighCm == this.rightThighCm &&
          other.leftCalfCm == this.leftCalfCm &&
          other.rightCalfCm == this.rightCalfCm &&
          other.notes == this.notes);
}

class BodyMeasurementsTableCompanion
    extends UpdateCompanion<BodyMeasurementsTableData> {
  final Value<int> id;
  final Value<int> profileId;
  final Value<DateTime> measuredAt;
  final Value<double> weightKg;
  final Value<double?> neckCm;
  final Value<double?> chestCm;
  final Value<double?> waistCm;
  final Value<double?> abdomenCm;
  final Value<double?> hipsCm;
  final Value<double?> leftArmCm;
  final Value<double?> rightArmCm;
  final Value<double?> leftThighCm;
  final Value<double?> rightThighCm;
  final Value<double?> leftCalfCm;
  final Value<double?> rightCalfCm;
  final Value<String?> notes;
  const BodyMeasurementsTableCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.measuredAt = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.neckCm = const Value.absent(),
    this.chestCm = const Value.absent(),
    this.waistCm = const Value.absent(),
    this.abdomenCm = const Value.absent(),
    this.hipsCm = const Value.absent(),
    this.leftArmCm = const Value.absent(),
    this.rightArmCm = const Value.absent(),
    this.leftThighCm = const Value.absent(),
    this.rightThighCm = const Value.absent(),
    this.leftCalfCm = const Value.absent(),
    this.rightCalfCm = const Value.absent(),
    this.notes = const Value.absent(),
  });
  BodyMeasurementsTableCompanion.insert({
    this.id = const Value.absent(),
    required int profileId,
    required DateTime measuredAt,
    required double weightKg,
    this.neckCm = const Value.absent(),
    this.chestCm = const Value.absent(),
    this.waistCm = const Value.absent(),
    this.abdomenCm = const Value.absent(),
    this.hipsCm = const Value.absent(),
    this.leftArmCm = const Value.absent(),
    this.rightArmCm = const Value.absent(),
    this.leftThighCm = const Value.absent(),
    this.rightThighCm = const Value.absent(),
    this.leftCalfCm = const Value.absent(),
    this.rightCalfCm = const Value.absent(),
    this.notes = const Value.absent(),
  }) : profileId = Value(profileId),
       measuredAt = Value(measuredAt),
       weightKg = Value(weightKg);
  static Insertable<BodyMeasurementsTableData> custom({
    Expression<int>? id,
    Expression<int>? profileId,
    Expression<DateTime>? measuredAt,
    Expression<double>? weightKg,
    Expression<double>? neckCm,
    Expression<double>? chestCm,
    Expression<double>? waistCm,
    Expression<double>? abdomenCm,
    Expression<double>? hipsCm,
    Expression<double>? leftArmCm,
    Expression<double>? rightArmCm,
    Expression<double>? leftThighCm,
    Expression<double>? rightThighCm,
    Expression<double>? leftCalfCm,
    Expression<double>? rightCalfCm,
    Expression<String>? notes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (measuredAt != null) 'measured_at': measuredAt,
      if (weightKg != null) 'weight_kg': weightKg,
      if (neckCm != null) 'neck_cm': neckCm,
      if (chestCm != null) 'chest_cm': chestCm,
      if (waistCm != null) 'waist_cm': waistCm,
      if (abdomenCm != null) 'abdomen_cm': abdomenCm,
      if (hipsCm != null) 'hips_cm': hipsCm,
      if (leftArmCm != null) 'left_arm_cm': leftArmCm,
      if (rightArmCm != null) 'right_arm_cm': rightArmCm,
      if (leftThighCm != null) 'left_thigh_cm': leftThighCm,
      if (rightThighCm != null) 'right_thigh_cm': rightThighCm,
      if (leftCalfCm != null) 'left_calf_cm': leftCalfCm,
      if (rightCalfCm != null) 'right_calf_cm': rightCalfCm,
      if (notes != null) 'notes': notes,
    });
  }

  BodyMeasurementsTableCompanion copyWith({
    Value<int>? id,
    Value<int>? profileId,
    Value<DateTime>? measuredAt,
    Value<double>? weightKg,
    Value<double?>? neckCm,
    Value<double?>? chestCm,
    Value<double?>? waistCm,
    Value<double?>? abdomenCm,
    Value<double?>? hipsCm,
    Value<double?>? leftArmCm,
    Value<double?>? rightArmCm,
    Value<double?>? leftThighCm,
    Value<double?>? rightThighCm,
    Value<double?>? leftCalfCm,
    Value<double?>? rightCalfCm,
    Value<String?>? notes,
  }) {
    return BodyMeasurementsTableCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      measuredAt: measuredAt ?? this.measuredAt,
      weightKg: weightKg ?? this.weightKg,
      neckCm: neckCm ?? this.neckCm,
      chestCm: chestCm ?? this.chestCm,
      waistCm: waistCm ?? this.waistCm,
      abdomenCm: abdomenCm ?? this.abdomenCm,
      hipsCm: hipsCm ?? this.hipsCm,
      leftArmCm: leftArmCm ?? this.leftArmCm,
      rightArmCm: rightArmCm ?? this.rightArmCm,
      leftThighCm: leftThighCm ?? this.leftThighCm,
      rightThighCm: rightThighCm ?? this.rightThighCm,
      leftCalfCm: leftCalfCm ?? this.leftCalfCm,
      rightCalfCm: rightCalfCm ?? this.rightCalfCm,
      notes: notes ?? this.notes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<int>(profileId.value);
    }
    if (measuredAt.present) {
      map['measured_at'] = Variable<DateTime>(measuredAt.value);
    }
    if (weightKg.present) {
      map['weight_kg'] = Variable<double>(weightKg.value);
    }
    if (neckCm.present) {
      map['neck_cm'] = Variable<double>(neckCm.value);
    }
    if (chestCm.present) {
      map['chest_cm'] = Variable<double>(chestCm.value);
    }
    if (waistCm.present) {
      map['waist_cm'] = Variable<double>(waistCm.value);
    }
    if (abdomenCm.present) {
      map['abdomen_cm'] = Variable<double>(abdomenCm.value);
    }
    if (hipsCm.present) {
      map['hips_cm'] = Variable<double>(hipsCm.value);
    }
    if (leftArmCm.present) {
      map['left_arm_cm'] = Variable<double>(leftArmCm.value);
    }
    if (rightArmCm.present) {
      map['right_arm_cm'] = Variable<double>(rightArmCm.value);
    }
    if (leftThighCm.present) {
      map['left_thigh_cm'] = Variable<double>(leftThighCm.value);
    }
    if (rightThighCm.present) {
      map['right_thigh_cm'] = Variable<double>(rightThighCm.value);
    }
    if (leftCalfCm.present) {
      map['left_calf_cm'] = Variable<double>(leftCalfCm.value);
    }
    if (rightCalfCm.present) {
      map['right_calf_cm'] = Variable<double>(rightCalfCm.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BodyMeasurementsTableCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('measuredAt: $measuredAt, ')
          ..write('weightKg: $weightKg, ')
          ..write('neckCm: $neckCm, ')
          ..write('chestCm: $chestCm, ')
          ..write('waistCm: $waistCm, ')
          ..write('abdomenCm: $abdomenCm, ')
          ..write('hipsCm: $hipsCm, ')
          ..write('leftArmCm: $leftArmCm, ')
          ..write('rightArmCm: $rightArmCm, ')
          ..write('leftThighCm: $leftThighCm, ')
          ..write('rightThighCm: $rightThighCm, ')
          ..write('leftCalfCm: $leftCalfCm, ')
          ..write('rightCalfCm: $rightCalfCm, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }
}

class $PressureMeasurementsTableTable extends PressureMeasurementsTable
    with
        TableInfo<
          $PressureMeasurementsTableTable,
          PressureMeasurementsTableData
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PressureMeasurementsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<int> profileId = GeneratedColumn<int>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES user_profiles_table (id)',
    ),
  );
  static const VerificationMeta _measuredAtMeta = const VerificationMeta(
    'measuredAt',
  );
  @override
  late final GeneratedColumn<DateTime> measuredAt = GeneratedColumn<DateTime>(
    'measured_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _systolicMeta = const VerificationMeta(
    'systolic',
  );
  @override
  late final GeneratedColumn<int> systolic = GeneratedColumn<int>(
    'systolic',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _diastolicMeta = const VerificationMeta(
    'diastolic',
  );
  @override
  late final GeneratedColumn<int> diastolic = GeneratedColumn<int>(
    'diastolic',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _heartRateMeta = const VerificationMeta(
    'heartRate',
  );
  @override
  late final GeneratedColumn<int> heartRate = GeneratedColumn<int>(
    'heart_rate',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _measurementContextMeta =
      const VerificationMeta('measurementContext');
  @override
  late final GeneratedColumn<String> measurementContext =
      GeneratedColumn<String>(
        'measurement_context',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    profileId,
    measuredAt,
    systolic,
    diastolic,
    heartRate,
    measurementContext,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pressure_measurements_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<PressureMeasurementsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('measured_at')) {
      context.handle(
        _measuredAtMeta,
        measuredAt.isAcceptableOrUnknown(data['measured_at']!, _measuredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_measuredAtMeta);
    }
    if (data.containsKey('systolic')) {
      context.handle(
        _systolicMeta,
        systolic.isAcceptableOrUnknown(data['systolic']!, _systolicMeta),
      );
    } else if (isInserting) {
      context.missing(_systolicMeta);
    }
    if (data.containsKey('diastolic')) {
      context.handle(
        _diastolicMeta,
        diastolic.isAcceptableOrUnknown(data['diastolic']!, _diastolicMeta),
      );
    } else if (isInserting) {
      context.missing(_diastolicMeta);
    }
    if (data.containsKey('heart_rate')) {
      context.handle(
        _heartRateMeta,
        heartRate.isAcceptableOrUnknown(data['heart_rate']!, _heartRateMeta),
      );
    }
    if (data.containsKey('measurement_context')) {
      context.handle(
        _measurementContextMeta,
        measurementContext.isAcceptableOrUnknown(
          data['measurement_context']!,
          _measurementContextMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PressureMeasurementsTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PressureMeasurementsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}profile_id'],
      )!,
      measuredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}measured_at'],
      )!,
      systolic: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}systolic'],
      )!,
      diastolic: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}diastolic'],
      )!,
      heartRate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}heart_rate'],
      ),
      measurementContext: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}measurement_context'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $PressureMeasurementsTableTable createAlias(String alias) {
    return $PressureMeasurementsTableTable(attachedDatabase, alias);
  }
}

class PressureMeasurementsTableData extends DataClass
    implements Insertable<PressureMeasurementsTableData> {
  final int id;
  final int profileId;
  final DateTime measuredAt;
  final int systolic;
  final int diastolic;
  final int? heartRate;
  final String? measurementContext;
  final String? notes;
  const PressureMeasurementsTableData({
    required this.id,
    required this.profileId,
    required this.measuredAt,
    required this.systolic,
    required this.diastolic,
    this.heartRate,
    this.measurementContext,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['profile_id'] = Variable<int>(profileId);
    map['measured_at'] = Variable<DateTime>(measuredAt);
    map['systolic'] = Variable<int>(systolic);
    map['diastolic'] = Variable<int>(diastolic);
    if (!nullToAbsent || heartRate != null) {
      map['heart_rate'] = Variable<int>(heartRate);
    }
    if (!nullToAbsent || measurementContext != null) {
      map['measurement_context'] = Variable<String>(measurementContext);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  PressureMeasurementsTableCompanion toCompanion(bool nullToAbsent) {
    return PressureMeasurementsTableCompanion(
      id: Value(id),
      profileId: Value(profileId),
      measuredAt: Value(measuredAt),
      systolic: Value(systolic),
      diastolic: Value(diastolic),
      heartRate: heartRate == null && nullToAbsent
          ? const Value.absent()
          : Value(heartRate),
      measurementContext: measurementContext == null && nullToAbsent
          ? const Value.absent()
          : Value(measurementContext),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory PressureMeasurementsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PressureMeasurementsTableData(
      id: serializer.fromJson<int>(json['id']),
      profileId: serializer.fromJson<int>(json['profileId']),
      measuredAt: serializer.fromJson<DateTime>(json['measuredAt']),
      systolic: serializer.fromJson<int>(json['systolic']),
      diastolic: serializer.fromJson<int>(json['diastolic']),
      heartRate: serializer.fromJson<int?>(json['heartRate']),
      measurementContext: serializer.fromJson<String?>(
        json['measurementContext'],
      ),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'profileId': serializer.toJson<int>(profileId),
      'measuredAt': serializer.toJson<DateTime>(measuredAt),
      'systolic': serializer.toJson<int>(systolic),
      'diastolic': serializer.toJson<int>(diastolic),
      'heartRate': serializer.toJson<int?>(heartRate),
      'measurementContext': serializer.toJson<String?>(measurementContext),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  PressureMeasurementsTableData copyWith({
    int? id,
    int? profileId,
    DateTime? measuredAt,
    int? systolic,
    int? diastolic,
    Value<int?> heartRate = const Value.absent(),
    Value<String?> measurementContext = const Value.absent(),
    Value<String?> notes = const Value.absent(),
  }) => PressureMeasurementsTableData(
    id: id ?? this.id,
    profileId: profileId ?? this.profileId,
    measuredAt: measuredAt ?? this.measuredAt,
    systolic: systolic ?? this.systolic,
    diastolic: diastolic ?? this.diastolic,
    heartRate: heartRate.present ? heartRate.value : this.heartRate,
    measurementContext: measurementContext.present
        ? measurementContext.value
        : this.measurementContext,
    notes: notes.present ? notes.value : this.notes,
  );
  PressureMeasurementsTableData copyWithCompanion(
    PressureMeasurementsTableCompanion data,
  ) {
    return PressureMeasurementsTableData(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      measuredAt: data.measuredAt.present
          ? data.measuredAt.value
          : this.measuredAt,
      systolic: data.systolic.present ? data.systolic.value : this.systolic,
      diastolic: data.diastolic.present ? data.diastolic.value : this.diastolic,
      heartRate: data.heartRate.present ? data.heartRate.value : this.heartRate,
      measurementContext: data.measurementContext.present
          ? data.measurementContext.value
          : this.measurementContext,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PressureMeasurementsTableData(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('measuredAt: $measuredAt, ')
          ..write('systolic: $systolic, ')
          ..write('diastolic: $diastolic, ')
          ..write('heartRate: $heartRate, ')
          ..write('measurementContext: $measurementContext, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    profileId,
    measuredAt,
    systolic,
    diastolic,
    heartRate,
    measurementContext,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PressureMeasurementsTableData &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.measuredAt == this.measuredAt &&
          other.systolic == this.systolic &&
          other.diastolic == this.diastolic &&
          other.heartRate == this.heartRate &&
          other.measurementContext == this.measurementContext &&
          other.notes == this.notes);
}

class PressureMeasurementsTableCompanion
    extends UpdateCompanion<PressureMeasurementsTableData> {
  final Value<int> id;
  final Value<int> profileId;
  final Value<DateTime> measuredAt;
  final Value<int> systolic;
  final Value<int> diastolic;
  final Value<int?> heartRate;
  final Value<String?> measurementContext;
  final Value<String?> notes;
  const PressureMeasurementsTableCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.measuredAt = const Value.absent(),
    this.systolic = const Value.absent(),
    this.diastolic = const Value.absent(),
    this.heartRate = const Value.absent(),
    this.measurementContext = const Value.absent(),
    this.notes = const Value.absent(),
  });
  PressureMeasurementsTableCompanion.insert({
    this.id = const Value.absent(),
    required int profileId,
    required DateTime measuredAt,
    required int systolic,
    required int diastolic,
    this.heartRate = const Value.absent(),
    this.measurementContext = const Value.absent(),
    this.notes = const Value.absent(),
  }) : profileId = Value(profileId),
       measuredAt = Value(measuredAt),
       systolic = Value(systolic),
       diastolic = Value(diastolic);
  static Insertable<PressureMeasurementsTableData> custom({
    Expression<int>? id,
    Expression<int>? profileId,
    Expression<DateTime>? measuredAt,
    Expression<int>? systolic,
    Expression<int>? diastolic,
    Expression<int>? heartRate,
    Expression<String>? measurementContext,
    Expression<String>? notes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (measuredAt != null) 'measured_at': measuredAt,
      if (systolic != null) 'systolic': systolic,
      if (diastolic != null) 'diastolic': diastolic,
      if (heartRate != null) 'heart_rate': heartRate,
      if (measurementContext != null) 'measurement_context': measurementContext,
      if (notes != null) 'notes': notes,
    });
  }

  PressureMeasurementsTableCompanion copyWith({
    Value<int>? id,
    Value<int>? profileId,
    Value<DateTime>? measuredAt,
    Value<int>? systolic,
    Value<int>? diastolic,
    Value<int?>? heartRate,
    Value<String?>? measurementContext,
    Value<String?>? notes,
  }) {
    return PressureMeasurementsTableCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      measuredAt: measuredAt ?? this.measuredAt,
      systolic: systolic ?? this.systolic,
      diastolic: diastolic ?? this.diastolic,
      heartRate: heartRate ?? this.heartRate,
      measurementContext: measurementContext ?? this.measurementContext,
      notes: notes ?? this.notes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<int>(profileId.value);
    }
    if (measuredAt.present) {
      map['measured_at'] = Variable<DateTime>(measuredAt.value);
    }
    if (systolic.present) {
      map['systolic'] = Variable<int>(systolic.value);
    }
    if (diastolic.present) {
      map['diastolic'] = Variable<int>(diastolic.value);
    }
    if (heartRate.present) {
      map['heart_rate'] = Variable<int>(heartRate.value);
    }
    if (measurementContext.present) {
      map['measurement_context'] = Variable<String>(measurementContext.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PressureMeasurementsTableCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('measuredAt: $measuredAt, ')
          ..write('systolic: $systolic, ')
          ..write('diastolic: $diastolic, ')
          ..write('heartRate: $heartRate, ')
          ..write('measurementContext: $measurementContext, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }
}

class $UserEquipmentTableTable extends UserEquipmentTable
    with TableInfo<$UserEquipmentTableTable, UserEquipmentTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserEquipmentTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<int> profileId = GeneratedColumn<int>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES user_profiles_table (id)',
    ),
  );
  static const VerificationMeta _equipmentCodeMeta = const VerificationMeta(
    'equipmentCode',
  );
  @override
  late final GeneratedColumn<String> equipmentCode = GeneratedColumn<String>(
    'equipment_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownedMeta = const VerificationMeta('owned');
  @override
  late final GeneratedColumn<bool> owned = GeneratedColumn<bool>(
    'owned',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("owned" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _acquiredAtMeta = const VerificationMeta(
    'acquiredAt',
  );
  @override
  late final GeneratedColumn<DateTime> acquiredAt = GeneratedColumn<DateTime>(
    'acquired_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    profileId,
    equipmentCode,
    owned,
    acquiredAt,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_equipment_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserEquipmentTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('equipment_code')) {
      context.handle(
        _equipmentCodeMeta,
        equipmentCode.isAcceptableOrUnknown(
          data['equipment_code']!,
          _equipmentCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_equipmentCodeMeta);
    }
    if (data.containsKey('owned')) {
      context.handle(
        _ownedMeta,
        owned.isAcceptableOrUnknown(data['owned']!, _ownedMeta),
      );
    }
    if (data.containsKey('acquired_at')) {
      context.handle(
        _acquiredAtMeta,
        acquiredAt.isAcceptableOrUnknown(data['acquired_at']!, _acquiredAtMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {profileId, equipmentCode},
  ];
  @override
  UserEquipmentTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserEquipmentTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}profile_id'],
      )!,
      equipmentCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}equipment_code'],
      )!,
      owned: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}owned'],
      )!,
      acquiredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}acquired_at'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $UserEquipmentTableTable createAlias(String alias) {
    return $UserEquipmentTableTable(attachedDatabase, alias);
  }
}

class UserEquipmentTableData extends DataClass
    implements Insertable<UserEquipmentTableData> {
  final int id;
  final int profileId;
  final String equipmentCode;
  final bool owned;
  final DateTime? acquiredAt;
  final String? notes;
  const UserEquipmentTableData({
    required this.id,
    required this.profileId,
    required this.equipmentCode,
    required this.owned,
    this.acquiredAt,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['profile_id'] = Variable<int>(profileId);
    map['equipment_code'] = Variable<String>(equipmentCode);
    map['owned'] = Variable<bool>(owned);
    if (!nullToAbsent || acquiredAt != null) {
      map['acquired_at'] = Variable<DateTime>(acquiredAt);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  UserEquipmentTableCompanion toCompanion(bool nullToAbsent) {
    return UserEquipmentTableCompanion(
      id: Value(id),
      profileId: Value(profileId),
      equipmentCode: Value(equipmentCode),
      owned: Value(owned),
      acquiredAt: acquiredAt == null && nullToAbsent
          ? const Value.absent()
          : Value(acquiredAt),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory UserEquipmentTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserEquipmentTableData(
      id: serializer.fromJson<int>(json['id']),
      profileId: serializer.fromJson<int>(json['profileId']),
      equipmentCode: serializer.fromJson<String>(json['equipmentCode']),
      owned: serializer.fromJson<bool>(json['owned']),
      acquiredAt: serializer.fromJson<DateTime?>(json['acquiredAt']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'profileId': serializer.toJson<int>(profileId),
      'equipmentCode': serializer.toJson<String>(equipmentCode),
      'owned': serializer.toJson<bool>(owned),
      'acquiredAt': serializer.toJson<DateTime?>(acquiredAt),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  UserEquipmentTableData copyWith({
    int? id,
    int? profileId,
    String? equipmentCode,
    bool? owned,
    Value<DateTime?> acquiredAt = const Value.absent(),
    Value<String?> notes = const Value.absent(),
  }) => UserEquipmentTableData(
    id: id ?? this.id,
    profileId: profileId ?? this.profileId,
    equipmentCode: equipmentCode ?? this.equipmentCode,
    owned: owned ?? this.owned,
    acquiredAt: acquiredAt.present ? acquiredAt.value : this.acquiredAt,
    notes: notes.present ? notes.value : this.notes,
  );
  UserEquipmentTableData copyWithCompanion(UserEquipmentTableCompanion data) {
    return UserEquipmentTableData(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      equipmentCode: data.equipmentCode.present
          ? data.equipmentCode.value
          : this.equipmentCode,
      owned: data.owned.present ? data.owned.value : this.owned,
      acquiredAt: data.acquiredAt.present
          ? data.acquiredAt.value
          : this.acquiredAt,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserEquipmentTableData(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('equipmentCode: $equipmentCode, ')
          ..write('owned: $owned, ')
          ..write('acquiredAt: $acquiredAt, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, profileId, equipmentCode, owned, acquiredAt, notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserEquipmentTableData &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.equipmentCode == this.equipmentCode &&
          other.owned == this.owned &&
          other.acquiredAt == this.acquiredAt &&
          other.notes == this.notes);
}

class UserEquipmentTableCompanion
    extends UpdateCompanion<UserEquipmentTableData> {
  final Value<int> id;
  final Value<int> profileId;
  final Value<String> equipmentCode;
  final Value<bool> owned;
  final Value<DateTime?> acquiredAt;
  final Value<String?> notes;
  const UserEquipmentTableCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.equipmentCode = const Value.absent(),
    this.owned = const Value.absent(),
    this.acquiredAt = const Value.absent(),
    this.notes = const Value.absent(),
  });
  UserEquipmentTableCompanion.insert({
    this.id = const Value.absent(),
    required int profileId,
    required String equipmentCode,
    this.owned = const Value.absent(),
    this.acquiredAt = const Value.absent(),
    this.notes = const Value.absent(),
  }) : profileId = Value(profileId),
       equipmentCode = Value(equipmentCode);
  static Insertable<UserEquipmentTableData> custom({
    Expression<int>? id,
    Expression<int>? profileId,
    Expression<String>? equipmentCode,
    Expression<bool>? owned,
    Expression<DateTime>? acquiredAt,
    Expression<String>? notes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (equipmentCode != null) 'equipment_code': equipmentCode,
      if (owned != null) 'owned': owned,
      if (acquiredAt != null) 'acquired_at': acquiredAt,
      if (notes != null) 'notes': notes,
    });
  }

  UserEquipmentTableCompanion copyWith({
    Value<int>? id,
    Value<int>? profileId,
    Value<String>? equipmentCode,
    Value<bool>? owned,
    Value<DateTime?>? acquiredAt,
    Value<String?>? notes,
  }) {
    return UserEquipmentTableCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      equipmentCode: equipmentCode ?? this.equipmentCode,
      owned: owned ?? this.owned,
      acquiredAt: acquiredAt ?? this.acquiredAt,
      notes: notes ?? this.notes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<int>(profileId.value);
    }
    if (equipmentCode.present) {
      map['equipment_code'] = Variable<String>(equipmentCode.value);
    }
    if (owned.present) {
      map['owned'] = Variable<bool>(owned.value);
    }
    if (acquiredAt.present) {
      map['acquired_at'] = Variable<DateTime>(acquiredAt.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserEquipmentTableCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('equipmentCode: $equipmentCode, ')
          ..write('owned: $owned, ')
          ..write('acquiredAt: $acquiredAt, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AppSettingsTableTable appSettingsTable = $AppSettingsTableTable(
    this,
  );
  late final $UserProfilesTableTable userProfilesTable =
      $UserProfilesTableTable(this);
  late final $BodyMeasurementsTableTable bodyMeasurementsTable =
      $BodyMeasurementsTableTable(this);
  late final $PressureMeasurementsTableTable pressureMeasurementsTable =
      $PressureMeasurementsTableTable(this);
  late final $UserEquipmentTableTable userEquipmentTable =
      $UserEquipmentTableTable(this);
  late final AppSettingsDao appSettingsDao = AppSettingsDao(
    this as AppDatabase,
  );
  late final UserProfileDao userProfileDao = UserProfileDao(
    this as AppDatabase,
  );
  late final BodyMeasurementsDao bodyMeasurementsDao = BodyMeasurementsDao(
    this as AppDatabase,
  );
  late final PressureMeasurementsDao pressureMeasurementsDao =
      PressureMeasurementsDao(this as AppDatabase);
  late final UserEquipmentDao userEquipmentDao = UserEquipmentDao(
    this as AppDatabase,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    appSettingsTable,
    userProfilesTable,
    bodyMeasurementsTable,
    pressureMeasurementsTable,
    userEquipmentTable,
  ];
}

typedef $$AppSettingsTableTableCreateCompanionBuilder =
    AppSettingsTableCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$AppSettingsTableTableUpdateCompanionBuilder =
    AppSettingsTableCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$AppSettingsTableTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTableTable> {
  $$AppSettingsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTableTable> {
  $$AppSettingsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTableTable> {
  $$AppSettingsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppSettingsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTableTable,
          AppSettingsTableData,
          $$AppSettingsTableTableFilterComposer,
          $$AppSettingsTableTableOrderingComposer,
          $$AppSettingsTableTableAnnotationComposer,
          $$AppSettingsTableTableCreateCompanionBuilder,
          $$AppSettingsTableTableUpdateCompanionBuilder,
          (
            AppSettingsTableData,
            BaseReferences<
              _$AppDatabase,
              $AppSettingsTableTable,
              AppSettingsTableData
            >,
          ),
          AppSettingsTableData,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableTableManager(
    _$AppDatabase db,
    $AppSettingsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsTableCompanion(
                key: key,
                value: value,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsTableCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTableTable,
      AppSettingsTableData,
      $$AppSettingsTableTableFilterComposer,
      $$AppSettingsTableTableOrderingComposer,
      $$AppSettingsTableTableAnnotationComposer,
      $$AppSettingsTableTableCreateCompanionBuilder,
      $$AppSettingsTableTableUpdateCompanionBuilder,
      (
        AppSettingsTableData,
        BaseReferences<
          _$AppDatabase,
          $AppSettingsTableTable,
          AppSettingsTableData
        >,
      ),
      AppSettingsTableData,
      PrefetchHooks Function()
    >;
typedef $$UserProfilesTableTableCreateCompanionBuilder =
    UserProfilesTableCompanion Function({
      Value<int> id,
      required String name,
      required DateTime birthDate,
      Value<String?> biologicalSexForFormula,
      required double heightCm,
      required double initialWeightKg,
      Value<double?> targetWeightKg,
      required int preferredWalkMinutes,
      required double equipmentBudgetLimit,
      required DateTime startDate,
      Value<String?> activityLevel,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$UserProfilesTableTableUpdateCompanionBuilder =
    UserProfilesTableCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<DateTime> birthDate,
      Value<String?> biologicalSexForFormula,
      Value<double> heightCm,
      Value<double> initialWeightKg,
      Value<double?> targetWeightKg,
      Value<int> preferredWalkMinutes,
      Value<double> equipmentBudgetLimit,
      Value<DateTime> startDate,
      Value<String?> activityLevel,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$UserProfilesTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $UserProfilesTableTable,
          UserProfilesTableData
        > {
  $$UserProfilesTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<
    $BodyMeasurementsTableTable,
    List<BodyMeasurementsTableData>
  >
  _bodyMeasurementsTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.bodyMeasurementsTable,
        aliasName:
            'user_profiles_table__id__body_measurements_table__profile_id',
      );

  $$BodyMeasurementsTableTableProcessedTableManager
  get bodyMeasurementsTableRefs {
    final manager = $$BodyMeasurementsTableTableTableManager(
      $_db,
      $_db.bodyMeasurementsTable,
    ).filter((f) => f.profileId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _bodyMeasurementsTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $PressureMeasurementsTableTable,
    List<PressureMeasurementsTableData>
  >
  _pressureMeasurementsTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.pressureMeasurementsTable,
        aliasName:
            'user_profiles_table__id__pressure_measurements_table__profile_id',
      );

  $$PressureMeasurementsTableTableProcessedTableManager
  get pressureMeasurementsTableRefs {
    final manager = $$PressureMeasurementsTableTableTableManager(
      $_db,
      $_db.pressureMeasurementsTable,
    ).filter((f) => f.profileId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _pressureMeasurementsTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $UserEquipmentTableTable,
    List<UserEquipmentTableData>
  >
  _userEquipmentTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.userEquipmentTable,
        aliasName: 'user_profiles_table__id__user_equipment_table__profile_id',
      );

  $$UserEquipmentTableTableProcessedTableManager get userEquipmentTableRefs {
    final manager = $$UserEquipmentTableTableTableManager(
      $_db,
      $_db.userEquipmentTable,
    ).filter((f) => f.profileId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _userEquipmentTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$UserProfilesTableTableFilterComposer
    extends Composer<_$AppDatabase, $UserProfilesTableTable> {
  $$UserProfilesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get birthDate => $composableBuilder(
    column: $table.birthDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get biologicalSexForFormula => $composableBuilder(
    column: $table.biologicalSexForFormula,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get heightCm => $composableBuilder(
    column: $table.heightCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get initialWeightKg => $composableBuilder(
    column: $table.initialWeightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get targetWeightKg => $composableBuilder(
    column: $table.targetWeightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get preferredWalkMinutes => $composableBuilder(
    column: $table.preferredWalkMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get equipmentBudgetLimit => $composableBuilder(
    column: $table.equipmentBudgetLimit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get activityLevel => $composableBuilder(
    column: $table.activityLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> bodyMeasurementsTableRefs(
    Expression<bool> Function($$BodyMeasurementsTableTableFilterComposer f) f,
  ) {
    final $$BodyMeasurementsTableTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.bodyMeasurementsTable,
          getReferencedColumn: (t) => t.profileId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$BodyMeasurementsTableTableFilterComposer(
                $db: $db,
                $table: $db.bodyMeasurementsTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> pressureMeasurementsTableRefs(
    Expression<bool> Function($$PressureMeasurementsTableTableFilterComposer f)
    f,
  ) {
    final $$PressureMeasurementsTableTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.pressureMeasurementsTable,
          getReferencedColumn: (t) => t.profileId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PressureMeasurementsTableTableFilterComposer(
                $db: $db,
                $table: $db.pressureMeasurementsTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> userEquipmentTableRefs(
    Expression<bool> Function($$UserEquipmentTableTableFilterComposer f) f,
  ) {
    final $$UserEquipmentTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userEquipmentTable,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserEquipmentTableTableFilterComposer(
            $db: $db,
            $table: $db.userEquipmentTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UserProfilesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $UserProfilesTableTable> {
  $$UserProfilesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get birthDate => $composableBuilder(
    column: $table.birthDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get biologicalSexForFormula => $composableBuilder(
    column: $table.biologicalSexForFormula,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get heightCm => $composableBuilder(
    column: $table.heightCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get initialWeightKg => $composableBuilder(
    column: $table.initialWeightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get targetWeightKg => $composableBuilder(
    column: $table.targetWeightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get preferredWalkMinutes => $composableBuilder(
    column: $table.preferredWalkMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get equipmentBudgetLimit => $composableBuilder(
    column: $table.equipmentBudgetLimit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get activityLevel => $composableBuilder(
    column: $table.activityLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserProfilesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserProfilesTableTable> {
  $$UserProfilesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get birthDate =>
      $composableBuilder(column: $table.birthDate, builder: (column) => column);

  GeneratedColumn<String> get biologicalSexForFormula => $composableBuilder(
    column: $table.biologicalSexForFormula,
    builder: (column) => column,
  );

  GeneratedColumn<double> get heightCm =>
      $composableBuilder(column: $table.heightCm, builder: (column) => column);

  GeneratedColumn<double> get initialWeightKg => $composableBuilder(
    column: $table.initialWeightKg,
    builder: (column) => column,
  );

  GeneratedColumn<double> get targetWeightKg => $composableBuilder(
    column: $table.targetWeightKg,
    builder: (column) => column,
  );

  GeneratedColumn<int> get preferredWalkMinutes => $composableBuilder(
    column: $table.preferredWalkMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<double> get equipmentBudgetLimit => $composableBuilder(
    column: $table.equipmentBudgetLimit,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<String> get activityLevel => $composableBuilder(
    column: $table.activityLevel,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> bodyMeasurementsTableRefs<T extends Object>(
    Expression<T> Function($$BodyMeasurementsTableTableAnnotationComposer a) f,
  ) {
    final $$BodyMeasurementsTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.bodyMeasurementsTable,
          getReferencedColumn: (t) => t.profileId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$BodyMeasurementsTableTableAnnotationComposer(
                $db: $db,
                $table: $db.bodyMeasurementsTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> pressureMeasurementsTableRefs<T extends Object>(
    Expression<T> Function($$PressureMeasurementsTableTableAnnotationComposer a)
    f,
  ) {
    final $$PressureMeasurementsTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.pressureMeasurementsTable,
          getReferencedColumn: (t) => t.profileId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PressureMeasurementsTableTableAnnotationComposer(
                $db: $db,
                $table: $db.pressureMeasurementsTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> userEquipmentTableRefs<T extends Object>(
    Expression<T> Function($$UserEquipmentTableTableAnnotationComposer a) f,
  ) {
    final $$UserEquipmentTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.userEquipmentTable,
          getReferencedColumn: (t) => t.profileId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$UserEquipmentTableTableAnnotationComposer(
                $db: $db,
                $table: $db.userEquipmentTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$UserProfilesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserProfilesTableTable,
          UserProfilesTableData,
          $$UserProfilesTableTableFilterComposer,
          $$UserProfilesTableTableOrderingComposer,
          $$UserProfilesTableTableAnnotationComposer,
          $$UserProfilesTableTableCreateCompanionBuilder,
          $$UserProfilesTableTableUpdateCompanionBuilder,
          (UserProfilesTableData, $$UserProfilesTableTableReferences),
          UserProfilesTableData,
          PrefetchHooks Function({
            bool bodyMeasurementsTableRefs,
            bool pressureMeasurementsTableRefs,
            bool userEquipmentTableRefs,
          })
        > {
  $$UserProfilesTableTableTableManager(
    _$AppDatabase db,
    $UserProfilesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserProfilesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserProfilesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserProfilesTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime> birthDate = const Value.absent(),
                Value<String?> biologicalSexForFormula = const Value.absent(),
                Value<double> heightCm = const Value.absent(),
                Value<double> initialWeightKg = const Value.absent(),
                Value<double?> targetWeightKg = const Value.absent(),
                Value<int> preferredWalkMinutes = const Value.absent(),
                Value<double> equipmentBudgetLimit = const Value.absent(),
                Value<DateTime> startDate = const Value.absent(),
                Value<String?> activityLevel = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => UserProfilesTableCompanion(
                id: id,
                name: name,
                birthDate: birthDate,
                biologicalSexForFormula: biologicalSexForFormula,
                heightCm: heightCm,
                initialWeightKg: initialWeightKg,
                targetWeightKg: targetWeightKg,
                preferredWalkMinutes: preferredWalkMinutes,
                equipmentBudgetLimit: equipmentBudgetLimit,
                startDate: startDate,
                activityLevel: activityLevel,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required DateTime birthDate,
                Value<String?> biologicalSexForFormula = const Value.absent(),
                required double heightCm,
                required double initialWeightKg,
                Value<double?> targetWeightKg = const Value.absent(),
                required int preferredWalkMinutes,
                required double equipmentBudgetLimit,
                required DateTime startDate,
                Value<String?> activityLevel = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => UserProfilesTableCompanion.insert(
                id: id,
                name: name,
                birthDate: birthDate,
                biologicalSexForFormula: biologicalSexForFormula,
                heightCm: heightCm,
                initialWeightKg: initialWeightKg,
                targetWeightKg: targetWeightKg,
                preferredWalkMinutes: preferredWalkMinutes,
                equipmentBudgetLimit: equipmentBudgetLimit,
                startDate: startDate,
                activityLevel: activityLevel,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$UserProfilesTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                bodyMeasurementsTableRefs = false,
                pressureMeasurementsTableRefs = false,
                userEquipmentTableRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (bodyMeasurementsTableRefs) db.bodyMeasurementsTable,
                    if (pressureMeasurementsTableRefs)
                      db.pressureMeasurementsTable,
                    if (userEquipmentTableRefs) db.userEquipmentTable,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (bodyMeasurementsTableRefs)
                        await $_getPrefetchedData<
                          UserProfilesTableData,
                          $UserProfilesTableTable,
                          BodyMeasurementsTableData
                        >(
                          currentTable: table,
                          referencedTable: $$UserProfilesTableTableReferences
                              ._bodyMeasurementsTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UserProfilesTableTableReferences(
                                db,
                                table,
                                p0,
                              ).bodyMeasurementsTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.profileId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (pressureMeasurementsTableRefs)
                        await $_getPrefetchedData<
                          UserProfilesTableData,
                          $UserProfilesTableTable,
                          PressureMeasurementsTableData
                        >(
                          currentTable: table,
                          referencedTable: $$UserProfilesTableTableReferences
                              ._pressureMeasurementsTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UserProfilesTableTableReferences(
                                db,
                                table,
                                p0,
                              ).pressureMeasurementsTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.profileId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (userEquipmentTableRefs)
                        await $_getPrefetchedData<
                          UserProfilesTableData,
                          $UserProfilesTableTable,
                          UserEquipmentTableData
                        >(
                          currentTable: table,
                          referencedTable: $$UserProfilesTableTableReferences
                              ._userEquipmentTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UserProfilesTableTableReferences(
                                db,
                                table,
                                p0,
                              ).userEquipmentTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.profileId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$UserProfilesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserProfilesTableTable,
      UserProfilesTableData,
      $$UserProfilesTableTableFilterComposer,
      $$UserProfilesTableTableOrderingComposer,
      $$UserProfilesTableTableAnnotationComposer,
      $$UserProfilesTableTableCreateCompanionBuilder,
      $$UserProfilesTableTableUpdateCompanionBuilder,
      (UserProfilesTableData, $$UserProfilesTableTableReferences),
      UserProfilesTableData,
      PrefetchHooks Function({
        bool bodyMeasurementsTableRefs,
        bool pressureMeasurementsTableRefs,
        bool userEquipmentTableRefs,
      })
    >;
typedef $$BodyMeasurementsTableTableCreateCompanionBuilder =
    BodyMeasurementsTableCompanion Function({
      Value<int> id,
      required int profileId,
      required DateTime measuredAt,
      required double weightKg,
      Value<double?> neckCm,
      Value<double?> chestCm,
      Value<double?> waistCm,
      Value<double?> abdomenCm,
      Value<double?> hipsCm,
      Value<double?> leftArmCm,
      Value<double?> rightArmCm,
      Value<double?> leftThighCm,
      Value<double?> rightThighCm,
      Value<double?> leftCalfCm,
      Value<double?> rightCalfCm,
      Value<String?> notes,
    });
typedef $$BodyMeasurementsTableTableUpdateCompanionBuilder =
    BodyMeasurementsTableCompanion Function({
      Value<int> id,
      Value<int> profileId,
      Value<DateTime> measuredAt,
      Value<double> weightKg,
      Value<double?> neckCm,
      Value<double?> chestCm,
      Value<double?> waistCm,
      Value<double?> abdomenCm,
      Value<double?> hipsCm,
      Value<double?> leftArmCm,
      Value<double?> rightArmCm,
      Value<double?> leftThighCm,
      Value<double?> rightThighCm,
      Value<double?> leftCalfCm,
      Value<double?> rightCalfCm,
      Value<String?> notes,
    });

final class $$BodyMeasurementsTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $BodyMeasurementsTableTable,
          BodyMeasurementsTableData
        > {
  $$BodyMeasurementsTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $UserProfilesTableTable _profileIdTable(_$AppDatabase db) =>
      db.userProfilesTable.createAlias(
        'body_measurements_table__profile_id__user_profiles_table__id',
      );

  $$UserProfilesTableTableProcessedTableManager get profileId {
    final $_column = $_itemColumn<int>('profile_id')!;

    final manager = $$UserProfilesTableTableTableManager(
      $_db,
      $_db.userProfilesTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$BodyMeasurementsTableTableFilterComposer
    extends Composer<_$AppDatabase, $BodyMeasurementsTableTable> {
  $$BodyMeasurementsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get measuredAt => $composableBuilder(
    column: $table.measuredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get neckCm => $composableBuilder(
    column: $table.neckCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get chestCm => $composableBuilder(
    column: $table.chestCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get waistCm => $composableBuilder(
    column: $table.waistCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get abdomenCm => $composableBuilder(
    column: $table.abdomenCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get hipsCm => $composableBuilder(
    column: $table.hipsCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get leftArmCm => $composableBuilder(
    column: $table.leftArmCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get rightArmCm => $composableBuilder(
    column: $table.rightArmCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get leftThighCm => $composableBuilder(
    column: $table.leftThighCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get rightThighCm => $composableBuilder(
    column: $table.rightThighCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get leftCalfCm => $composableBuilder(
    column: $table.leftCalfCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get rightCalfCm => $composableBuilder(
    column: $table.rightCalfCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  $$UserProfilesTableTableFilterComposer get profileId {
    final $$UserProfilesTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.userProfilesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserProfilesTableTableFilterComposer(
            $db: $db,
            $table: $db.userProfilesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BodyMeasurementsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $BodyMeasurementsTableTable> {
  $$BodyMeasurementsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get measuredAt => $composableBuilder(
    column: $table.measuredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get neckCm => $composableBuilder(
    column: $table.neckCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get chestCm => $composableBuilder(
    column: $table.chestCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get waistCm => $composableBuilder(
    column: $table.waistCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get abdomenCm => $composableBuilder(
    column: $table.abdomenCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get hipsCm => $composableBuilder(
    column: $table.hipsCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get leftArmCm => $composableBuilder(
    column: $table.leftArmCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rightArmCm => $composableBuilder(
    column: $table.rightArmCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get leftThighCm => $composableBuilder(
    column: $table.leftThighCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rightThighCm => $composableBuilder(
    column: $table.rightThighCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get leftCalfCm => $composableBuilder(
    column: $table.leftCalfCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rightCalfCm => $composableBuilder(
    column: $table.rightCalfCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  $$UserProfilesTableTableOrderingComposer get profileId {
    final $$UserProfilesTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.userProfilesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserProfilesTableTableOrderingComposer(
            $db: $db,
            $table: $db.userProfilesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BodyMeasurementsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $BodyMeasurementsTableTable> {
  $$BodyMeasurementsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get measuredAt => $composableBuilder(
    column: $table.measuredAt,
    builder: (column) => column,
  );

  GeneratedColumn<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => column);

  GeneratedColumn<double> get neckCm =>
      $composableBuilder(column: $table.neckCm, builder: (column) => column);

  GeneratedColumn<double> get chestCm =>
      $composableBuilder(column: $table.chestCm, builder: (column) => column);

  GeneratedColumn<double> get waistCm =>
      $composableBuilder(column: $table.waistCm, builder: (column) => column);

  GeneratedColumn<double> get abdomenCm =>
      $composableBuilder(column: $table.abdomenCm, builder: (column) => column);

  GeneratedColumn<double> get hipsCm =>
      $composableBuilder(column: $table.hipsCm, builder: (column) => column);

  GeneratedColumn<double> get leftArmCm =>
      $composableBuilder(column: $table.leftArmCm, builder: (column) => column);

  GeneratedColumn<double> get rightArmCm => $composableBuilder(
    column: $table.rightArmCm,
    builder: (column) => column,
  );

  GeneratedColumn<double> get leftThighCm => $composableBuilder(
    column: $table.leftThighCm,
    builder: (column) => column,
  );

  GeneratedColumn<double> get rightThighCm => $composableBuilder(
    column: $table.rightThighCm,
    builder: (column) => column,
  );

  GeneratedColumn<double> get leftCalfCm => $composableBuilder(
    column: $table.leftCalfCm,
    builder: (column) => column,
  );

  GeneratedColumn<double> get rightCalfCm => $composableBuilder(
    column: $table.rightCalfCm,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  $$UserProfilesTableTableAnnotationComposer get profileId {
    final $$UserProfilesTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.profileId,
          referencedTable: $db.userProfilesTable,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$UserProfilesTableTableAnnotationComposer(
                $db: $db,
                $table: $db.userProfilesTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$BodyMeasurementsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BodyMeasurementsTableTable,
          BodyMeasurementsTableData,
          $$BodyMeasurementsTableTableFilterComposer,
          $$BodyMeasurementsTableTableOrderingComposer,
          $$BodyMeasurementsTableTableAnnotationComposer,
          $$BodyMeasurementsTableTableCreateCompanionBuilder,
          $$BodyMeasurementsTableTableUpdateCompanionBuilder,
          (BodyMeasurementsTableData, $$BodyMeasurementsTableTableReferences),
          BodyMeasurementsTableData,
          PrefetchHooks Function({bool profileId})
        > {
  $$BodyMeasurementsTableTableTableManager(
    _$AppDatabase db,
    $BodyMeasurementsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BodyMeasurementsTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$BodyMeasurementsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$BodyMeasurementsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> profileId = const Value.absent(),
                Value<DateTime> measuredAt = const Value.absent(),
                Value<double> weightKg = const Value.absent(),
                Value<double?> neckCm = const Value.absent(),
                Value<double?> chestCm = const Value.absent(),
                Value<double?> waistCm = const Value.absent(),
                Value<double?> abdomenCm = const Value.absent(),
                Value<double?> hipsCm = const Value.absent(),
                Value<double?> leftArmCm = const Value.absent(),
                Value<double?> rightArmCm = const Value.absent(),
                Value<double?> leftThighCm = const Value.absent(),
                Value<double?> rightThighCm = const Value.absent(),
                Value<double?> leftCalfCm = const Value.absent(),
                Value<double?> rightCalfCm = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => BodyMeasurementsTableCompanion(
                id: id,
                profileId: profileId,
                measuredAt: measuredAt,
                weightKg: weightKg,
                neckCm: neckCm,
                chestCm: chestCm,
                waistCm: waistCm,
                abdomenCm: abdomenCm,
                hipsCm: hipsCm,
                leftArmCm: leftArmCm,
                rightArmCm: rightArmCm,
                leftThighCm: leftThighCm,
                rightThighCm: rightThighCm,
                leftCalfCm: leftCalfCm,
                rightCalfCm: rightCalfCm,
                notes: notes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int profileId,
                required DateTime measuredAt,
                required double weightKg,
                Value<double?> neckCm = const Value.absent(),
                Value<double?> chestCm = const Value.absent(),
                Value<double?> waistCm = const Value.absent(),
                Value<double?> abdomenCm = const Value.absent(),
                Value<double?> hipsCm = const Value.absent(),
                Value<double?> leftArmCm = const Value.absent(),
                Value<double?> rightArmCm = const Value.absent(),
                Value<double?> leftThighCm = const Value.absent(),
                Value<double?> rightThighCm = const Value.absent(),
                Value<double?> leftCalfCm = const Value.absent(),
                Value<double?> rightCalfCm = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => BodyMeasurementsTableCompanion.insert(
                id: id,
                profileId: profileId,
                measuredAt: measuredAt,
                weightKg: weightKg,
                neckCm: neckCm,
                chestCm: chestCm,
                waistCm: waistCm,
                abdomenCm: abdomenCm,
                hipsCm: hipsCm,
                leftArmCm: leftArmCm,
                rightArmCm: rightArmCm,
                leftThighCm: leftThighCm,
                rightThighCm: rightThighCm,
                leftCalfCm: leftCalfCm,
                rightCalfCm: rightCalfCm,
                notes: notes,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$BodyMeasurementsTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({profileId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (profileId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.profileId,
                                referencedTable:
                                    $$BodyMeasurementsTableTableReferences
                                        ._profileIdTable(db),
                                referencedColumn:
                                    $$BodyMeasurementsTableTableReferences
                                        ._profileIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$BodyMeasurementsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BodyMeasurementsTableTable,
      BodyMeasurementsTableData,
      $$BodyMeasurementsTableTableFilterComposer,
      $$BodyMeasurementsTableTableOrderingComposer,
      $$BodyMeasurementsTableTableAnnotationComposer,
      $$BodyMeasurementsTableTableCreateCompanionBuilder,
      $$BodyMeasurementsTableTableUpdateCompanionBuilder,
      (BodyMeasurementsTableData, $$BodyMeasurementsTableTableReferences),
      BodyMeasurementsTableData,
      PrefetchHooks Function({bool profileId})
    >;
typedef $$PressureMeasurementsTableTableCreateCompanionBuilder =
    PressureMeasurementsTableCompanion Function({
      Value<int> id,
      required int profileId,
      required DateTime measuredAt,
      required int systolic,
      required int diastolic,
      Value<int?> heartRate,
      Value<String?> measurementContext,
      Value<String?> notes,
    });
typedef $$PressureMeasurementsTableTableUpdateCompanionBuilder =
    PressureMeasurementsTableCompanion Function({
      Value<int> id,
      Value<int> profileId,
      Value<DateTime> measuredAt,
      Value<int> systolic,
      Value<int> diastolic,
      Value<int?> heartRate,
      Value<String?> measurementContext,
      Value<String?> notes,
    });

final class $$PressureMeasurementsTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $PressureMeasurementsTableTable,
          PressureMeasurementsTableData
        > {
  $$PressureMeasurementsTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $UserProfilesTableTable _profileIdTable(_$AppDatabase db) =>
      db.userProfilesTable.createAlias(
        'pressure_measurements_table__profile_id__user_profiles_table__id',
      );

  $$UserProfilesTableTableProcessedTableManager get profileId {
    final $_column = $_itemColumn<int>('profile_id')!;

    final manager = $$UserProfilesTableTableTableManager(
      $_db,
      $_db.userProfilesTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PressureMeasurementsTableTableFilterComposer
    extends Composer<_$AppDatabase, $PressureMeasurementsTableTable> {
  $$PressureMeasurementsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get measuredAt => $composableBuilder(
    column: $table.measuredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get systolic => $composableBuilder(
    column: $table.systolic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get diastolic => $composableBuilder(
    column: $table.diastolic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get heartRate => $composableBuilder(
    column: $table.heartRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get measurementContext => $composableBuilder(
    column: $table.measurementContext,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  $$UserProfilesTableTableFilterComposer get profileId {
    final $$UserProfilesTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.userProfilesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserProfilesTableTableFilterComposer(
            $db: $db,
            $table: $db.userProfilesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PressureMeasurementsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PressureMeasurementsTableTable> {
  $$PressureMeasurementsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get measuredAt => $composableBuilder(
    column: $table.measuredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get systolic => $composableBuilder(
    column: $table.systolic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get diastolic => $composableBuilder(
    column: $table.diastolic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get heartRate => $composableBuilder(
    column: $table.heartRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get measurementContext => $composableBuilder(
    column: $table.measurementContext,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  $$UserProfilesTableTableOrderingComposer get profileId {
    final $$UserProfilesTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.userProfilesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserProfilesTableTableOrderingComposer(
            $db: $db,
            $table: $db.userProfilesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PressureMeasurementsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PressureMeasurementsTableTable> {
  $$PressureMeasurementsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get measuredAt => $composableBuilder(
    column: $table.measuredAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get systolic =>
      $composableBuilder(column: $table.systolic, builder: (column) => column);

  GeneratedColumn<int> get diastolic =>
      $composableBuilder(column: $table.diastolic, builder: (column) => column);

  GeneratedColumn<int> get heartRate =>
      $composableBuilder(column: $table.heartRate, builder: (column) => column);

  GeneratedColumn<String> get measurementContext => $composableBuilder(
    column: $table.measurementContext,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  $$UserProfilesTableTableAnnotationComposer get profileId {
    final $$UserProfilesTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.profileId,
          referencedTable: $db.userProfilesTable,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$UserProfilesTableTableAnnotationComposer(
                $db: $db,
                $table: $db.userProfilesTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$PressureMeasurementsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PressureMeasurementsTableTable,
          PressureMeasurementsTableData,
          $$PressureMeasurementsTableTableFilterComposer,
          $$PressureMeasurementsTableTableOrderingComposer,
          $$PressureMeasurementsTableTableAnnotationComposer,
          $$PressureMeasurementsTableTableCreateCompanionBuilder,
          $$PressureMeasurementsTableTableUpdateCompanionBuilder,
          (
            PressureMeasurementsTableData,
            $$PressureMeasurementsTableTableReferences,
          ),
          PressureMeasurementsTableData,
          PrefetchHooks Function({bool profileId})
        > {
  $$PressureMeasurementsTableTableTableManager(
    _$AppDatabase db,
    $PressureMeasurementsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PressureMeasurementsTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$PressureMeasurementsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$PressureMeasurementsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> profileId = const Value.absent(),
                Value<DateTime> measuredAt = const Value.absent(),
                Value<int> systolic = const Value.absent(),
                Value<int> diastolic = const Value.absent(),
                Value<int?> heartRate = const Value.absent(),
                Value<String?> measurementContext = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => PressureMeasurementsTableCompanion(
                id: id,
                profileId: profileId,
                measuredAt: measuredAt,
                systolic: systolic,
                diastolic: diastolic,
                heartRate: heartRate,
                measurementContext: measurementContext,
                notes: notes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int profileId,
                required DateTime measuredAt,
                required int systolic,
                required int diastolic,
                Value<int?> heartRate = const Value.absent(),
                Value<String?> measurementContext = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => PressureMeasurementsTableCompanion.insert(
                id: id,
                profileId: profileId,
                measuredAt: measuredAt,
                systolic: systolic,
                diastolic: diastolic,
                heartRate: heartRate,
                measurementContext: measurementContext,
                notes: notes,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PressureMeasurementsTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({profileId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (profileId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.profileId,
                                referencedTable:
                                    $$PressureMeasurementsTableTableReferences
                                        ._profileIdTable(db),
                                referencedColumn:
                                    $$PressureMeasurementsTableTableReferences
                                        ._profileIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PressureMeasurementsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PressureMeasurementsTableTable,
      PressureMeasurementsTableData,
      $$PressureMeasurementsTableTableFilterComposer,
      $$PressureMeasurementsTableTableOrderingComposer,
      $$PressureMeasurementsTableTableAnnotationComposer,
      $$PressureMeasurementsTableTableCreateCompanionBuilder,
      $$PressureMeasurementsTableTableUpdateCompanionBuilder,
      (
        PressureMeasurementsTableData,
        $$PressureMeasurementsTableTableReferences,
      ),
      PressureMeasurementsTableData,
      PrefetchHooks Function({bool profileId})
    >;
typedef $$UserEquipmentTableTableCreateCompanionBuilder =
    UserEquipmentTableCompanion Function({
      Value<int> id,
      required int profileId,
      required String equipmentCode,
      Value<bool> owned,
      Value<DateTime?> acquiredAt,
      Value<String?> notes,
    });
typedef $$UserEquipmentTableTableUpdateCompanionBuilder =
    UserEquipmentTableCompanion Function({
      Value<int> id,
      Value<int> profileId,
      Value<String> equipmentCode,
      Value<bool> owned,
      Value<DateTime?> acquiredAt,
      Value<String?> notes,
    });

final class $$UserEquipmentTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $UserEquipmentTableTable,
          UserEquipmentTableData
        > {
  $$UserEquipmentTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $UserProfilesTableTable _profileIdTable(_$AppDatabase db) => db
      .userProfilesTable
      .createAlias('user_equipment_table__profile_id__user_profiles_table__id');

  $$UserProfilesTableTableProcessedTableManager get profileId {
    final $_column = $_itemColumn<int>('profile_id')!;

    final manager = $$UserProfilesTableTableTableManager(
      $_db,
      $_db.userProfilesTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$UserEquipmentTableTableFilterComposer
    extends Composer<_$AppDatabase, $UserEquipmentTableTable> {
  $$UserEquipmentTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get equipmentCode => $composableBuilder(
    column: $table.equipmentCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get owned => $composableBuilder(
    column: $table.owned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get acquiredAt => $composableBuilder(
    column: $table.acquiredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  $$UserProfilesTableTableFilterComposer get profileId {
    final $$UserProfilesTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.userProfilesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserProfilesTableTableFilterComposer(
            $db: $db,
            $table: $db.userProfilesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UserEquipmentTableTableOrderingComposer
    extends Composer<_$AppDatabase, $UserEquipmentTableTable> {
  $$UserEquipmentTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get equipmentCode => $composableBuilder(
    column: $table.equipmentCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get owned => $composableBuilder(
    column: $table.owned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get acquiredAt => $composableBuilder(
    column: $table.acquiredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  $$UserProfilesTableTableOrderingComposer get profileId {
    final $$UserProfilesTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.userProfilesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserProfilesTableTableOrderingComposer(
            $db: $db,
            $table: $db.userProfilesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UserEquipmentTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserEquipmentTableTable> {
  $$UserEquipmentTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get equipmentCode => $composableBuilder(
    column: $table.equipmentCode,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get owned =>
      $composableBuilder(column: $table.owned, builder: (column) => column);

  GeneratedColumn<DateTime> get acquiredAt => $composableBuilder(
    column: $table.acquiredAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  $$UserProfilesTableTableAnnotationComposer get profileId {
    final $$UserProfilesTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.profileId,
          referencedTable: $db.userProfilesTable,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$UserProfilesTableTableAnnotationComposer(
                $db: $db,
                $table: $db.userProfilesTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$UserEquipmentTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserEquipmentTableTable,
          UserEquipmentTableData,
          $$UserEquipmentTableTableFilterComposer,
          $$UserEquipmentTableTableOrderingComposer,
          $$UserEquipmentTableTableAnnotationComposer,
          $$UserEquipmentTableTableCreateCompanionBuilder,
          $$UserEquipmentTableTableUpdateCompanionBuilder,
          (UserEquipmentTableData, $$UserEquipmentTableTableReferences),
          UserEquipmentTableData,
          PrefetchHooks Function({bool profileId})
        > {
  $$UserEquipmentTableTableTableManager(
    _$AppDatabase db,
    $UserEquipmentTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserEquipmentTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserEquipmentTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserEquipmentTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> profileId = const Value.absent(),
                Value<String> equipmentCode = const Value.absent(),
                Value<bool> owned = const Value.absent(),
                Value<DateTime?> acquiredAt = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => UserEquipmentTableCompanion(
                id: id,
                profileId: profileId,
                equipmentCode: equipmentCode,
                owned: owned,
                acquiredAt: acquiredAt,
                notes: notes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int profileId,
                required String equipmentCode,
                Value<bool> owned = const Value.absent(),
                Value<DateTime?> acquiredAt = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => UserEquipmentTableCompanion.insert(
                id: id,
                profileId: profileId,
                equipmentCode: equipmentCode,
                owned: owned,
                acquiredAt: acquiredAt,
                notes: notes,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$UserEquipmentTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({profileId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (profileId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.profileId,
                                referencedTable:
                                    $$UserEquipmentTableTableReferences
                                        ._profileIdTable(db),
                                referencedColumn:
                                    $$UserEquipmentTableTableReferences
                                        ._profileIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$UserEquipmentTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserEquipmentTableTable,
      UserEquipmentTableData,
      $$UserEquipmentTableTableFilterComposer,
      $$UserEquipmentTableTableOrderingComposer,
      $$UserEquipmentTableTableAnnotationComposer,
      $$UserEquipmentTableTableCreateCompanionBuilder,
      $$UserEquipmentTableTableUpdateCompanionBuilder,
      (UserEquipmentTableData, $$UserEquipmentTableTableReferences),
      UserEquipmentTableData,
      PrefetchHooks Function({bool profileId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AppSettingsTableTableTableManager get appSettingsTable =>
      $$AppSettingsTableTableTableManager(_db, _db.appSettingsTable);
  $$UserProfilesTableTableTableManager get userProfilesTable =>
      $$UserProfilesTableTableTableManager(_db, _db.userProfilesTable);
  $$BodyMeasurementsTableTableTableManager get bodyMeasurementsTable =>
      $$BodyMeasurementsTableTableTableManager(_db, _db.bodyMeasurementsTable);
  $$PressureMeasurementsTableTableTableManager get pressureMeasurementsTable =>
      $$PressureMeasurementsTableTableTableManager(
        _db,
        _db.pressureMeasurementsTable,
      );
  $$UserEquipmentTableTableTableManager get userEquipmentTable =>
      $$UserEquipmentTableTableTableManager(_db, _db.userEquipmentTable);
}
