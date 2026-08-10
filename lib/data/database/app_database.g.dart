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
  static const String $name = 'impostazioni_app';
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
  static const String $name = 'profili_utente';
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
      'REFERENCES profili_utente (id)',
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
  static const String $name = 'misurazioni_corporee';
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
      'REFERENCES profili_utente (id)',
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
  static const String $name = 'misurazioni_pressione';
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
      'REFERENCES profili_utente (id)',
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
  static const String $name = 'attrezzature_utente';
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

class $CategorieEserciziTableTable extends CategorieEserciziTable
    with TableInfo<$CategorieEserciziTableTable, CategorieEserciziTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategorieEserciziTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _codiceMeta = const VerificationMeta('codice');
  @override
  late final GeneratedColumn<String> codice = GeneratedColumn<String>(
    'codice',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _nomeMeta = const VerificationMeta('nome');
  @override
  late final GeneratedColumn<String> nome = GeneratedColumn<String>(
    'nome',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descrizioneMeta = const VerificationMeta(
    'descrizione',
  );
  @override
  late final GeneratedColumn<String> descrizione = GeneratedColumn<String>(
    'descrizione',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ordineVisualizzazioneMeta =
      const VerificationMeta('ordineVisualizzazione');
  @override
  late final GeneratedColumn<int> ordineVisualizzazione = GeneratedColumn<int>(
    'ordine_visualizzazione',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _attivaMeta = const VerificationMeta('attiva');
  @override
  late final GeneratedColumn<bool> attiva = GeneratedColumn<bool>(
    'attiva',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("attiva" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _dataCreazioneMeta = const VerificationMeta(
    'dataCreazione',
  );
  @override
  late final GeneratedColumn<DateTime> dataCreazione =
      GeneratedColumn<DateTime>(
        'data_creazione',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _dataModificaMeta = const VerificationMeta(
    'dataModifica',
  );
  @override
  late final GeneratedColumn<DateTime> dataModifica = GeneratedColumn<DateTime>(
    'data_modifica',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    codice,
    nome,
    descrizione,
    ordineVisualizzazione,
    attiva,
    dataCreazione,
    dataModifica,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categorie_esercizi';
  @override
  VerificationContext validateIntegrity(
    Insertable<CategorieEserciziTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('codice')) {
      context.handle(
        _codiceMeta,
        codice.isAcceptableOrUnknown(data['codice']!, _codiceMeta),
      );
    } else if (isInserting) {
      context.missing(_codiceMeta);
    }
    if (data.containsKey('nome')) {
      context.handle(
        _nomeMeta,
        nome.isAcceptableOrUnknown(data['nome']!, _nomeMeta),
      );
    } else if (isInserting) {
      context.missing(_nomeMeta);
    }
    if (data.containsKey('descrizione')) {
      context.handle(
        _descrizioneMeta,
        descrizione.isAcceptableOrUnknown(
          data['descrizione']!,
          _descrizioneMeta,
        ),
      );
    }
    if (data.containsKey('ordine_visualizzazione')) {
      context.handle(
        _ordineVisualizzazioneMeta,
        ordineVisualizzazione.isAcceptableOrUnknown(
          data['ordine_visualizzazione']!,
          _ordineVisualizzazioneMeta,
        ),
      );
    }
    if (data.containsKey('attiva')) {
      context.handle(
        _attivaMeta,
        attiva.isAcceptableOrUnknown(data['attiva']!, _attivaMeta),
      );
    }
    if (data.containsKey('data_creazione')) {
      context.handle(
        _dataCreazioneMeta,
        dataCreazione.isAcceptableOrUnknown(
          data['data_creazione']!,
          _dataCreazioneMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dataCreazioneMeta);
    }
    if (data.containsKey('data_modifica')) {
      context.handle(
        _dataModificaMeta,
        dataModifica.isAcceptableOrUnknown(
          data['data_modifica']!,
          _dataModificaMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dataModificaMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CategorieEserciziTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategorieEserciziTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      codice: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}codice'],
      )!,
      nome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nome'],
      )!,
      descrizione: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}descrizione'],
      ),
      ordineVisualizzazione: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ordine_visualizzazione'],
      )!,
      attiva: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}attiva'],
      )!,
      dataCreazione: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}data_creazione'],
      )!,
      dataModifica: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}data_modifica'],
      )!,
    );
  }

  @override
  $CategorieEserciziTableTable createAlias(String alias) {
    return $CategorieEserciziTableTable(attachedDatabase, alias);
  }
}

class CategorieEserciziTableData extends DataClass
    implements Insertable<CategorieEserciziTableData> {
  final int id;
  final String codice;
  final String nome;
  final String? descrizione;
  final int ordineVisualizzazione;
  final bool attiva;
  final DateTime dataCreazione;
  final DateTime dataModifica;
  const CategorieEserciziTableData({
    required this.id,
    required this.codice,
    required this.nome,
    this.descrizione,
    required this.ordineVisualizzazione,
    required this.attiva,
    required this.dataCreazione,
    required this.dataModifica,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['codice'] = Variable<String>(codice);
    map['nome'] = Variable<String>(nome);
    if (!nullToAbsent || descrizione != null) {
      map['descrizione'] = Variable<String>(descrizione);
    }
    map['ordine_visualizzazione'] = Variable<int>(ordineVisualizzazione);
    map['attiva'] = Variable<bool>(attiva);
    map['data_creazione'] = Variable<DateTime>(dataCreazione);
    map['data_modifica'] = Variable<DateTime>(dataModifica);
    return map;
  }

  CategorieEserciziTableCompanion toCompanion(bool nullToAbsent) {
    return CategorieEserciziTableCompanion(
      id: Value(id),
      codice: Value(codice),
      nome: Value(nome),
      descrizione: descrizione == null && nullToAbsent
          ? const Value.absent()
          : Value(descrizione),
      ordineVisualizzazione: Value(ordineVisualizzazione),
      attiva: Value(attiva),
      dataCreazione: Value(dataCreazione),
      dataModifica: Value(dataModifica),
    );
  }

  factory CategorieEserciziTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategorieEserciziTableData(
      id: serializer.fromJson<int>(json['id']),
      codice: serializer.fromJson<String>(json['codice']),
      nome: serializer.fromJson<String>(json['nome']),
      descrizione: serializer.fromJson<String?>(json['descrizione']),
      ordineVisualizzazione: serializer.fromJson<int>(
        json['ordineVisualizzazione'],
      ),
      attiva: serializer.fromJson<bool>(json['attiva']),
      dataCreazione: serializer.fromJson<DateTime>(json['dataCreazione']),
      dataModifica: serializer.fromJson<DateTime>(json['dataModifica']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'codice': serializer.toJson<String>(codice),
      'nome': serializer.toJson<String>(nome),
      'descrizione': serializer.toJson<String?>(descrizione),
      'ordineVisualizzazione': serializer.toJson<int>(ordineVisualizzazione),
      'attiva': serializer.toJson<bool>(attiva),
      'dataCreazione': serializer.toJson<DateTime>(dataCreazione),
      'dataModifica': serializer.toJson<DateTime>(dataModifica),
    };
  }

  CategorieEserciziTableData copyWith({
    int? id,
    String? codice,
    String? nome,
    Value<String?> descrizione = const Value.absent(),
    int? ordineVisualizzazione,
    bool? attiva,
    DateTime? dataCreazione,
    DateTime? dataModifica,
  }) => CategorieEserciziTableData(
    id: id ?? this.id,
    codice: codice ?? this.codice,
    nome: nome ?? this.nome,
    descrizione: descrizione.present ? descrizione.value : this.descrizione,
    ordineVisualizzazione: ordineVisualizzazione ?? this.ordineVisualizzazione,
    attiva: attiva ?? this.attiva,
    dataCreazione: dataCreazione ?? this.dataCreazione,
    dataModifica: dataModifica ?? this.dataModifica,
  );
  CategorieEserciziTableData copyWithCompanion(
    CategorieEserciziTableCompanion data,
  ) {
    return CategorieEserciziTableData(
      id: data.id.present ? data.id.value : this.id,
      codice: data.codice.present ? data.codice.value : this.codice,
      nome: data.nome.present ? data.nome.value : this.nome,
      descrizione: data.descrizione.present
          ? data.descrizione.value
          : this.descrizione,
      ordineVisualizzazione: data.ordineVisualizzazione.present
          ? data.ordineVisualizzazione.value
          : this.ordineVisualizzazione,
      attiva: data.attiva.present ? data.attiva.value : this.attiva,
      dataCreazione: data.dataCreazione.present
          ? data.dataCreazione.value
          : this.dataCreazione,
      dataModifica: data.dataModifica.present
          ? data.dataModifica.value
          : this.dataModifica,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CategorieEserciziTableData(')
          ..write('id: $id, ')
          ..write('codice: $codice, ')
          ..write('nome: $nome, ')
          ..write('descrizione: $descrizione, ')
          ..write('ordineVisualizzazione: $ordineVisualizzazione, ')
          ..write('attiva: $attiva, ')
          ..write('dataCreazione: $dataCreazione, ')
          ..write('dataModifica: $dataModifica')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    codice,
    nome,
    descrizione,
    ordineVisualizzazione,
    attiva,
    dataCreazione,
    dataModifica,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategorieEserciziTableData &&
          other.id == this.id &&
          other.codice == this.codice &&
          other.nome == this.nome &&
          other.descrizione == this.descrizione &&
          other.ordineVisualizzazione == this.ordineVisualizzazione &&
          other.attiva == this.attiva &&
          other.dataCreazione == this.dataCreazione &&
          other.dataModifica == this.dataModifica);
}

class CategorieEserciziTableCompanion
    extends UpdateCompanion<CategorieEserciziTableData> {
  final Value<int> id;
  final Value<String> codice;
  final Value<String> nome;
  final Value<String?> descrizione;
  final Value<int> ordineVisualizzazione;
  final Value<bool> attiva;
  final Value<DateTime> dataCreazione;
  final Value<DateTime> dataModifica;
  const CategorieEserciziTableCompanion({
    this.id = const Value.absent(),
    this.codice = const Value.absent(),
    this.nome = const Value.absent(),
    this.descrizione = const Value.absent(),
    this.ordineVisualizzazione = const Value.absent(),
    this.attiva = const Value.absent(),
    this.dataCreazione = const Value.absent(),
    this.dataModifica = const Value.absent(),
  });
  CategorieEserciziTableCompanion.insert({
    this.id = const Value.absent(),
    required String codice,
    required String nome,
    this.descrizione = const Value.absent(),
    this.ordineVisualizzazione = const Value.absent(),
    this.attiva = const Value.absent(),
    required DateTime dataCreazione,
    required DateTime dataModifica,
  }) : codice = Value(codice),
       nome = Value(nome),
       dataCreazione = Value(dataCreazione),
       dataModifica = Value(dataModifica);
  static Insertable<CategorieEserciziTableData> custom({
    Expression<int>? id,
    Expression<String>? codice,
    Expression<String>? nome,
    Expression<String>? descrizione,
    Expression<int>? ordineVisualizzazione,
    Expression<bool>? attiva,
    Expression<DateTime>? dataCreazione,
    Expression<DateTime>? dataModifica,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (codice != null) 'codice': codice,
      if (nome != null) 'nome': nome,
      if (descrizione != null) 'descrizione': descrizione,
      if (ordineVisualizzazione != null)
        'ordine_visualizzazione': ordineVisualizzazione,
      if (attiva != null) 'attiva': attiva,
      if (dataCreazione != null) 'data_creazione': dataCreazione,
      if (dataModifica != null) 'data_modifica': dataModifica,
    });
  }

  CategorieEserciziTableCompanion copyWith({
    Value<int>? id,
    Value<String>? codice,
    Value<String>? nome,
    Value<String?>? descrizione,
    Value<int>? ordineVisualizzazione,
    Value<bool>? attiva,
    Value<DateTime>? dataCreazione,
    Value<DateTime>? dataModifica,
  }) {
    return CategorieEserciziTableCompanion(
      id: id ?? this.id,
      codice: codice ?? this.codice,
      nome: nome ?? this.nome,
      descrizione: descrizione ?? this.descrizione,
      ordineVisualizzazione:
          ordineVisualizzazione ?? this.ordineVisualizzazione,
      attiva: attiva ?? this.attiva,
      dataCreazione: dataCreazione ?? this.dataCreazione,
      dataModifica: dataModifica ?? this.dataModifica,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (codice.present) {
      map['codice'] = Variable<String>(codice.value);
    }
    if (nome.present) {
      map['nome'] = Variable<String>(nome.value);
    }
    if (descrizione.present) {
      map['descrizione'] = Variable<String>(descrizione.value);
    }
    if (ordineVisualizzazione.present) {
      map['ordine_visualizzazione'] = Variable<int>(
        ordineVisualizzazione.value,
      );
    }
    if (attiva.present) {
      map['attiva'] = Variable<bool>(attiva.value);
    }
    if (dataCreazione.present) {
      map['data_creazione'] = Variable<DateTime>(dataCreazione.value);
    }
    if (dataModifica.present) {
      map['data_modifica'] = Variable<DateTime>(dataModifica.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategorieEserciziTableCompanion(')
          ..write('id: $id, ')
          ..write('codice: $codice, ')
          ..write('nome: $nome, ')
          ..write('descrizione: $descrizione, ')
          ..write('ordineVisualizzazione: $ordineVisualizzazione, ')
          ..write('attiva: $attiva, ')
          ..write('dataCreazione: $dataCreazione, ')
          ..write('dataModifica: $dataModifica')
          ..write(')'))
        .toString();
  }
}

class $GruppiMuscolariTableTable extends GruppiMuscolariTable
    with TableInfo<$GruppiMuscolariTableTable, GruppiMuscolariTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GruppiMuscolariTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _codiceMeta = const VerificationMeta('codice');
  @override
  late final GeneratedColumn<String> codice = GeneratedColumn<String>(
    'codice',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _nomeMeta = const VerificationMeta('nome');
  @override
  late final GeneratedColumn<String> nome = GeneratedColumn<String>(
    'nome',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descrizioneMeta = const VerificationMeta(
    'descrizione',
  );
  @override
  late final GeneratedColumn<String> descrizione = GeneratedColumn<String>(
    'descrizione',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _attivoMeta = const VerificationMeta('attivo');
  @override
  late final GeneratedColumn<bool> attivo = GeneratedColumn<bool>(
    'attivo',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("attivo" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _dataCreazioneMeta = const VerificationMeta(
    'dataCreazione',
  );
  @override
  late final GeneratedColumn<DateTime> dataCreazione =
      GeneratedColumn<DateTime>(
        'data_creazione',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _dataModificaMeta = const VerificationMeta(
    'dataModifica',
  );
  @override
  late final GeneratedColumn<DateTime> dataModifica = GeneratedColumn<DateTime>(
    'data_modifica',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    codice,
    nome,
    descrizione,
    attivo,
    dataCreazione,
    dataModifica,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'gruppi_muscolari';
  @override
  VerificationContext validateIntegrity(
    Insertable<GruppiMuscolariTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('codice')) {
      context.handle(
        _codiceMeta,
        codice.isAcceptableOrUnknown(data['codice']!, _codiceMeta),
      );
    } else if (isInserting) {
      context.missing(_codiceMeta);
    }
    if (data.containsKey('nome')) {
      context.handle(
        _nomeMeta,
        nome.isAcceptableOrUnknown(data['nome']!, _nomeMeta),
      );
    } else if (isInserting) {
      context.missing(_nomeMeta);
    }
    if (data.containsKey('descrizione')) {
      context.handle(
        _descrizioneMeta,
        descrizione.isAcceptableOrUnknown(
          data['descrizione']!,
          _descrizioneMeta,
        ),
      );
    }
    if (data.containsKey('attivo')) {
      context.handle(
        _attivoMeta,
        attivo.isAcceptableOrUnknown(data['attivo']!, _attivoMeta),
      );
    }
    if (data.containsKey('data_creazione')) {
      context.handle(
        _dataCreazioneMeta,
        dataCreazione.isAcceptableOrUnknown(
          data['data_creazione']!,
          _dataCreazioneMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dataCreazioneMeta);
    }
    if (data.containsKey('data_modifica')) {
      context.handle(
        _dataModificaMeta,
        dataModifica.isAcceptableOrUnknown(
          data['data_modifica']!,
          _dataModificaMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dataModificaMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GruppiMuscolariTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GruppiMuscolariTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      codice: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}codice'],
      )!,
      nome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nome'],
      )!,
      descrizione: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}descrizione'],
      ),
      attivo: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}attivo'],
      )!,
      dataCreazione: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}data_creazione'],
      )!,
      dataModifica: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}data_modifica'],
      )!,
    );
  }

  @override
  $GruppiMuscolariTableTable createAlias(String alias) {
    return $GruppiMuscolariTableTable(attachedDatabase, alias);
  }
}

class GruppiMuscolariTableData extends DataClass
    implements Insertable<GruppiMuscolariTableData> {
  final int id;
  final String codice;
  final String nome;
  final String? descrizione;
  final bool attivo;
  final DateTime dataCreazione;
  final DateTime dataModifica;
  const GruppiMuscolariTableData({
    required this.id,
    required this.codice,
    required this.nome,
    this.descrizione,
    required this.attivo,
    required this.dataCreazione,
    required this.dataModifica,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['codice'] = Variable<String>(codice);
    map['nome'] = Variable<String>(nome);
    if (!nullToAbsent || descrizione != null) {
      map['descrizione'] = Variable<String>(descrizione);
    }
    map['attivo'] = Variable<bool>(attivo);
    map['data_creazione'] = Variable<DateTime>(dataCreazione);
    map['data_modifica'] = Variable<DateTime>(dataModifica);
    return map;
  }

  GruppiMuscolariTableCompanion toCompanion(bool nullToAbsent) {
    return GruppiMuscolariTableCompanion(
      id: Value(id),
      codice: Value(codice),
      nome: Value(nome),
      descrizione: descrizione == null && nullToAbsent
          ? const Value.absent()
          : Value(descrizione),
      attivo: Value(attivo),
      dataCreazione: Value(dataCreazione),
      dataModifica: Value(dataModifica),
    );
  }

  factory GruppiMuscolariTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GruppiMuscolariTableData(
      id: serializer.fromJson<int>(json['id']),
      codice: serializer.fromJson<String>(json['codice']),
      nome: serializer.fromJson<String>(json['nome']),
      descrizione: serializer.fromJson<String?>(json['descrizione']),
      attivo: serializer.fromJson<bool>(json['attivo']),
      dataCreazione: serializer.fromJson<DateTime>(json['dataCreazione']),
      dataModifica: serializer.fromJson<DateTime>(json['dataModifica']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'codice': serializer.toJson<String>(codice),
      'nome': serializer.toJson<String>(nome),
      'descrizione': serializer.toJson<String?>(descrizione),
      'attivo': serializer.toJson<bool>(attivo),
      'dataCreazione': serializer.toJson<DateTime>(dataCreazione),
      'dataModifica': serializer.toJson<DateTime>(dataModifica),
    };
  }

  GruppiMuscolariTableData copyWith({
    int? id,
    String? codice,
    String? nome,
    Value<String?> descrizione = const Value.absent(),
    bool? attivo,
    DateTime? dataCreazione,
    DateTime? dataModifica,
  }) => GruppiMuscolariTableData(
    id: id ?? this.id,
    codice: codice ?? this.codice,
    nome: nome ?? this.nome,
    descrizione: descrizione.present ? descrizione.value : this.descrizione,
    attivo: attivo ?? this.attivo,
    dataCreazione: dataCreazione ?? this.dataCreazione,
    dataModifica: dataModifica ?? this.dataModifica,
  );
  GruppiMuscolariTableData copyWithCompanion(
    GruppiMuscolariTableCompanion data,
  ) {
    return GruppiMuscolariTableData(
      id: data.id.present ? data.id.value : this.id,
      codice: data.codice.present ? data.codice.value : this.codice,
      nome: data.nome.present ? data.nome.value : this.nome,
      descrizione: data.descrizione.present
          ? data.descrizione.value
          : this.descrizione,
      attivo: data.attivo.present ? data.attivo.value : this.attivo,
      dataCreazione: data.dataCreazione.present
          ? data.dataCreazione.value
          : this.dataCreazione,
      dataModifica: data.dataModifica.present
          ? data.dataModifica.value
          : this.dataModifica,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GruppiMuscolariTableData(')
          ..write('id: $id, ')
          ..write('codice: $codice, ')
          ..write('nome: $nome, ')
          ..write('descrizione: $descrizione, ')
          ..write('attivo: $attivo, ')
          ..write('dataCreazione: $dataCreazione, ')
          ..write('dataModifica: $dataModifica')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    codice,
    nome,
    descrizione,
    attivo,
    dataCreazione,
    dataModifica,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GruppiMuscolariTableData &&
          other.id == this.id &&
          other.codice == this.codice &&
          other.nome == this.nome &&
          other.descrizione == this.descrizione &&
          other.attivo == this.attivo &&
          other.dataCreazione == this.dataCreazione &&
          other.dataModifica == this.dataModifica);
}

class GruppiMuscolariTableCompanion
    extends UpdateCompanion<GruppiMuscolariTableData> {
  final Value<int> id;
  final Value<String> codice;
  final Value<String> nome;
  final Value<String?> descrizione;
  final Value<bool> attivo;
  final Value<DateTime> dataCreazione;
  final Value<DateTime> dataModifica;
  const GruppiMuscolariTableCompanion({
    this.id = const Value.absent(),
    this.codice = const Value.absent(),
    this.nome = const Value.absent(),
    this.descrizione = const Value.absent(),
    this.attivo = const Value.absent(),
    this.dataCreazione = const Value.absent(),
    this.dataModifica = const Value.absent(),
  });
  GruppiMuscolariTableCompanion.insert({
    this.id = const Value.absent(),
    required String codice,
    required String nome,
    this.descrizione = const Value.absent(),
    this.attivo = const Value.absent(),
    required DateTime dataCreazione,
    required DateTime dataModifica,
  }) : codice = Value(codice),
       nome = Value(nome),
       dataCreazione = Value(dataCreazione),
       dataModifica = Value(dataModifica);
  static Insertable<GruppiMuscolariTableData> custom({
    Expression<int>? id,
    Expression<String>? codice,
    Expression<String>? nome,
    Expression<String>? descrizione,
    Expression<bool>? attivo,
    Expression<DateTime>? dataCreazione,
    Expression<DateTime>? dataModifica,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (codice != null) 'codice': codice,
      if (nome != null) 'nome': nome,
      if (descrizione != null) 'descrizione': descrizione,
      if (attivo != null) 'attivo': attivo,
      if (dataCreazione != null) 'data_creazione': dataCreazione,
      if (dataModifica != null) 'data_modifica': dataModifica,
    });
  }

  GruppiMuscolariTableCompanion copyWith({
    Value<int>? id,
    Value<String>? codice,
    Value<String>? nome,
    Value<String?>? descrizione,
    Value<bool>? attivo,
    Value<DateTime>? dataCreazione,
    Value<DateTime>? dataModifica,
  }) {
    return GruppiMuscolariTableCompanion(
      id: id ?? this.id,
      codice: codice ?? this.codice,
      nome: nome ?? this.nome,
      descrizione: descrizione ?? this.descrizione,
      attivo: attivo ?? this.attivo,
      dataCreazione: dataCreazione ?? this.dataCreazione,
      dataModifica: dataModifica ?? this.dataModifica,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (codice.present) {
      map['codice'] = Variable<String>(codice.value);
    }
    if (nome.present) {
      map['nome'] = Variable<String>(nome.value);
    }
    if (descrizione.present) {
      map['descrizione'] = Variable<String>(descrizione.value);
    }
    if (attivo.present) {
      map['attivo'] = Variable<bool>(attivo.value);
    }
    if (dataCreazione.present) {
      map['data_creazione'] = Variable<DateTime>(dataCreazione.value);
    }
    if (dataModifica.present) {
      map['data_modifica'] = Variable<DateTime>(dataModifica.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GruppiMuscolariTableCompanion(')
          ..write('id: $id, ')
          ..write('codice: $codice, ')
          ..write('nome: $nome, ')
          ..write('descrizione: $descrizione, ')
          ..write('attivo: $attivo, ')
          ..write('dataCreazione: $dataCreazione, ')
          ..write('dataModifica: $dataModifica')
          ..write(')'))
        .toString();
  }
}

class $EserciziTableTable extends EserciziTable
    with TableInfo<$EserciziTableTable, EserciziTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EserciziTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _codiceMeta = const VerificationMeta('codice');
  @override
  late final GeneratedColumn<String> codice = GeneratedColumn<String>(
    'codice',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _nomeMeta = const VerificationMeta('nome');
  @override
  late final GeneratedColumn<String> nome = GeneratedColumn<String>(
    'nome',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descrizioneMeta = const VerificationMeta(
    'descrizione',
  );
  @override
  late final GeneratedColumn<String> descrizione = GeneratedColumn<String>(
    'descrizione',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _istruzioniMeta = const VerificationMeta(
    'istruzioni',
  );
  @override
  late final GeneratedColumn<String> istruzioni = GeneratedColumn<String>(
    'istruzioni',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _istruzioniRespirazioneMeta =
      const VerificationMeta('istruzioniRespirazione');
  @override
  late final GeneratedColumn<String> istruzioniRespirazione =
      GeneratedColumn<String>(
        'istruzioni_respirazione',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _noteSicurezzaMeta = const VerificationMeta(
    'noteSicurezza',
  );
  @override
  late final GeneratedColumn<String> noteSicurezza = GeneratedColumn<String>(
    'note_sicurezza',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _erroriComuniMeta = const VerificationMeta(
    'erroriComuni',
  );
  @override
  late final GeneratedColumn<String> erroriComuni = GeneratedColumn<String>(
    'errori_comuni',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idCategoriaMeta = const VerificationMeta(
    'idCategoria',
  );
  @override
  late final GeneratedColumn<int> idCategoria = GeneratedColumn<int>(
    'id_categoria',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categorie_esercizi (id)',
    ),
  );
  static const VerificationMeta _livelloMinimoMeta = const VerificationMeta(
    'livelloMinimo',
  );
  @override
  late final GeneratedColumn<int> livelloMinimo = GeneratedColumn<int>(
    'livello_minimo',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _livelloMassimoMeta = const VerificationMeta(
    'livelloMassimo',
  );
  @override
  late final GeneratedColumn<int> livelloMassimo = GeneratedColumn<int>(
    'livello_massimo',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _livelloImpattoMeta = const VerificationMeta(
    'livelloImpatto',
  );
  @override
  late final GeneratedColumn<String> livelloImpatto = GeneratedColumn<String>(
    'livello_impatto',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _intensitaCardioMeta = const VerificationMeta(
    'intensitaCardio',
  );
  @override
  late final GeneratedColumn<String> intensitaCardio = GeneratedColumn<String>(
    'intensita_cardio',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _richiedeEquilibrioMeta =
      const VerificationMeta('richiedeEquilibrio');
  @override
  late final GeneratedColumn<bool> richiedeEquilibrio = GeneratedColumn<bool>(
    'richiede_equilibrio',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("richiede_equilibrio" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _richiedePavimentoMeta = const VerificationMeta(
    'richiedePavimento',
  );
  @override
  late final GeneratedColumn<bool> richiedePavimento = GeneratedColumn<bool>(
    'richiede_pavimento',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("richiede_pavimento" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _richiedePosizioneErettaMeta =
      const VerificationMeta('richiedePosizioneEretta');
  @override
  late final GeneratedColumn<bool> richiedePosizioneEretta =
      GeneratedColumn<bool>(
        'richiede_posizione_eretta',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("richiede_posizione_eretta" IN (0, 1))',
        ),
        defaultValue: const Constant(false),
      );
  static const VerificationMeta _supportoConsentitoMeta =
      const VerificationMeta('supportoConsentito');
  @override
  late final GeneratedColumn<bool> supportoConsentito = GeneratedColumn<bool>(
    'supporto_consentito',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("supporto_consentito" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _seriePredefiniteMeta = const VerificationMeta(
    'seriePredefinite',
  );
  @override
  late final GeneratedColumn<int> seriePredefinite = GeneratedColumn<int>(
    'serie_predefinite',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ripetizioniPredefiniteMeta =
      const VerificationMeta('ripetizioniPredefinite');
  @override
  late final GeneratedColumn<int> ripetizioniPredefinite = GeneratedColumn<int>(
    'ripetizioni_predefinite',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durataPredefinitaSecondiMeta =
      const VerificationMeta('durataPredefinitaSecondi');
  @override
  late final GeneratedColumn<int> durataPredefinitaSecondi =
      GeneratedColumn<int>(
        'durata_predefinita_secondi',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _recuperoPredefinitoSecondiMeta =
      const VerificationMeta('recuperoPredefinitoSecondi');
  @override
  late final GeneratedColumn<int> recuperoPredefinitoSecondi =
      GeneratedColumn<int>(
        'recupero_predefinito_secondi',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _esercizioSistemaMeta = const VerificationMeta(
    'esercizioSistema',
  );
  @override
  late final GeneratedColumn<bool> esercizioSistema = GeneratedColumn<bool>(
    'esercizio_sistema',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("esercizio_sistema" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _attivoMeta = const VerificationMeta('attivo');
  @override
  late final GeneratedColumn<bool> attivo = GeneratedColumn<bool>(
    'attivo',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("attivo" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _versioneCatalogoMeta = const VerificationMeta(
    'versioneCatalogo',
  );
  @override
  late final GeneratedColumn<int> versioneCatalogo = GeneratedColumn<int>(
    'versione_catalogo',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dataCreazioneMeta = const VerificationMeta(
    'dataCreazione',
  );
  @override
  late final GeneratedColumn<DateTime> dataCreazione =
      GeneratedColumn<DateTime>(
        'data_creazione',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _dataModificaMeta = const VerificationMeta(
    'dataModifica',
  );
  @override
  late final GeneratedColumn<DateTime> dataModifica = GeneratedColumn<DateTime>(
    'data_modifica',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    codice,
    nome,
    descrizione,
    istruzioni,
    istruzioniRespirazione,
    noteSicurezza,
    erroriComuni,
    idCategoria,
    livelloMinimo,
    livelloMassimo,
    livelloImpatto,
    intensitaCardio,
    richiedeEquilibrio,
    richiedePavimento,
    richiedePosizioneEretta,
    supportoConsentito,
    seriePredefinite,
    ripetizioniPredefinite,
    durataPredefinitaSecondi,
    recuperoPredefinitoSecondi,
    esercizioSistema,
    attivo,
    versioneCatalogo,
    dataCreazione,
    dataModifica,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'esercizi';
  @override
  VerificationContext validateIntegrity(
    Insertable<EserciziTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('codice')) {
      context.handle(
        _codiceMeta,
        codice.isAcceptableOrUnknown(data['codice']!, _codiceMeta),
      );
    } else if (isInserting) {
      context.missing(_codiceMeta);
    }
    if (data.containsKey('nome')) {
      context.handle(
        _nomeMeta,
        nome.isAcceptableOrUnknown(data['nome']!, _nomeMeta),
      );
    } else if (isInserting) {
      context.missing(_nomeMeta);
    }
    if (data.containsKey('descrizione')) {
      context.handle(
        _descrizioneMeta,
        descrizione.isAcceptableOrUnknown(
          data['descrizione']!,
          _descrizioneMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descrizioneMeta);
    }
    if (data.containsKey('istruzioni')) {
      context.handle(
        _istruzioniMeta,
        istruzioni.isAcceptableOrUnknown(data['istruzioni']!, _istruzioniMeta),
      );
    } else if (isInserting) {
      context.missing(_istruzioniMeta);
    }
    if (data.containsKey('istruzioni_respirazione')) {
      context.handle(
        _istruzioniRespirazioneMeta,
        istruzioniRespirazione.isAcceptableOrUnknown(
          data['istruzioni_respirazione']!,
          _istruzioniRespirazioneMeta,
        ),
      );
    }
    if (data.containsKey('note_sicurezza')) {
      context.handle(
        _noteSicurezzaMeta,
        noteSicurezza.isAcceptableOrUnknown(
          data['note_sicurezza']!,
          _noteSicurezzaMeta,
        ),
      );
    }
    if (data.containsKey('errori_comuni')) {
      context.handle(
        _erroriComuniMeta,
        erroriComuni.isAcceptableOrUnknown(
          data['errori_comuni']!,
          _erroriComuniMeta,
        ),
      );
    }
    if (data.containsKey('id_categoria')) {
      context.handle(
        _idCategoriaMeta,
        idCategoria.isAcceptableOrUnknown(
          data['id_categoria']!,
          _idCategoriaMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_idCategoriaMeta);
    }
    if (data.containsKey('livello_minimo')) {
      context.handle(
        _livelloMinimoMeta,
        livelloMinimo.isAcceptableOrUnknown(
          data['livello_minimo']!,
          _livelloMinimoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_livelloMinimoMeta);
    }
    if (data.containsKey('livello_massimo')) {
      context.handle(
        _livelloMassimoMeta,
        livelloMassimo.isAcceptableOrUnknown(
          data['livello_massimo']!,
          _livelloMassimoMeta,
        ),
      );
    }
    if (data.containsKey('livello_impatto')) {
      context.handle(
        _livelloImpattoMeta,
        livelloImpatto.isAcceptableOrUnknown(
          data['livello_impatto']!,
          _livelloImpattoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_livelloImpattoMeta);
    }
    if (data.containsKey('intensita_cardio')) {
      context.handle(
        _intensitaCardioMeta,
        intensitaCardio.isAcceptableOrUnknown(
          data['intensita_cardio']!,
          _intensitaCardioMeta,
        ),
      );
    }
    if (data.containsKey('richiede_equilibrio')) {
      context.handle(
        _richiedeEquilibrioMeta,
        richiedeEquilibrio.isAcceptableOrUnknown(
          data['richiede_equilibrio']!,
          _richiedeEquilibrioMeta,
        ),
      );
    }
    if (data.containsKey('richiede_pavimento')) {
      context.handle(
        _richiedePavimentoMeta,
        richiedePavimento.isAcceptableOrUnknown(
          data['richiede_pavimento']!,
          _richiedePavimentoMeta,
        ),
      );
    }
    if (data.containsKey('richiede_posizione_eretta')) {
      context.handle(
        _richiedePosizioneErettaMeta,
        richiedePosizioneEretta.isAcceptableOrUnknown(
          data['richiede_posizione_eretta']!,
          _richiedePosizioneErettaMeta,
        ),
      );
    }
    if (data.containsKey('supporto_consentito')) {
      context.handle(
        _supportoConsentitoMeta,
        supportoConsentito.isAcceptableOrUnknown(
          data['supporto_consentito']!,
          _supportoConsentitoMeta,
        ),
      );
    }
    if (data.containsKey('serie_predefinite')) {
      context.handle(
        _seriePredefiniteMeta,
        seriePredefinite.isAcceptableOrUnknown(
          data['serie_predefinite']!,
          _seriePredefiniteMeta,
        ),
      );
    }
    if (data.containsKey('ripetizioni_predefinite')) {
      context.handle(
        _ripetizioniPredefiniteMeta,
        ripetizioniPredefinite.isAcceptableOrUnknown(
          data['ripetizioni_predefinite']!,
          _ripetizioniPredefiniteMeta,
        ),
      );
    }
    if (data.containsKey('durata_predefinita_secondi')) {
      context.handle(
        _durataPredefinitaSecondiMeta,
        durataPredefinitaSecondi.isAcceptableOrUnknown(
          data['durata_predefinita_secondi']!,
          _durataPredefinitaSecondiMeta,
        ),
      );
    }
    if (data.containsKey('recupero_predefinito_secondi')) {
      context.handle(
        _recuperoPredefinitoSecondiMeta,
        recuperoPredefinitoSecondi.isAcceptableOrUnknown(
          data['recupero_predefinito_secondi']!,
          _recuperoPredefinitoSecondiMeta,
        ),
      );
    }
    if (data.containsKey('esercizio_sistema')) {
      context.handle(
        _esercizioSistemaMeta,
        esercizioSistema.isAcceptableOrUnknown(
          data['esercizio_sistema']!,
          _esercizioSistemaMeta,
        ),
      );
    }
    if (data.containsKey('attivo')) {
      context.handle(
        _attivoMeta,
        attivo.isAcceptableOrUnknown(data['attivo']!, _attivoMeta),
      );
    }
    if (data.containsKey('versione_catalogo')) {
      context.handle(
        _versioneCatalogoMeta,
        versioneCatalogo.isAcceptableOrUnknown(
          data['versione_catalogo']!,
          _versioneCatalogoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_versioneCatalogoMeta);
    }
    if (data.containsKey('data_creazione')) {
      context.handle(
        _dataCreazioneMeta,
        dataCreazione.isAcceptableOrUnknown(
          data['data_creazione']!,
          _dataCreazioneMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dataCreazioneMeta);
    }
    if (data.containsKey('data_modifica')) {
      context.handle(
        _dataModificaMeta,
        dataModifica.isAcceptableOrUnknown(
          data['data_modifica']!,
          _dataModificaMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dataModificaMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EserciziTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EserciziTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      codice: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}codice'],
      )!,
      nome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nome'],
      )!,
      descrizione: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}descrizione'],
      )!,
      istruzioni: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}istruzioni'],
      )!,
      istruzioniRespirazione: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}istruzioni_respirazione'],
      ),
      noteSicurezza: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note_sicurezza'],
      ),
      erroriComuni: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}errori_comuni'],
      ),
      idCategoria: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id_categoria'],
      )!,
      livelloMinimo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}livello_minimo'],
      )!,
      livelloMassimo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}livello_massimo'],
      ),
      livelloImpatto: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}livello_impatto'],
      )!,
      intensitaCardio: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}intensita_cardio'],
      ),
      richiedeEquilibrio: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}richiede_equilibrio'],
      )!,
      richiedePavimento: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}richiede_pavimento'],
      )!,
      richiedePosizioneEretta: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}richiede_posizione_eretta'],
      )!,
      supportoConsentito: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}supporto_consentito'],
      )!,
      seriePredefinite: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}serie_predefinite'],
      ),
      ripetizioniPredefinite: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ripetizioni_predefinite'],
      ),
      durataPredefinitaSecondi: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}durata_predefinita_secondi'],
      ),
      recuperoPredefinitoSecondi: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}recupero_predefinito_secondi'],
      ),
      esercizioSistema: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}esercizio_sistema'],
      )!,
      attivo: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}attivo'],
      )!,
      versioneCatalogo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}versione_catalogo'],
      )!,
      dataCreazione: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}data_creazione'],
      )!,
      dataModifica: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}data_modifica'],
      )!,
    );
  }

  @override
  $EserciziTableTable createAlias(String alias) {
    return $EserciziTableTable(attachedDatabase, alias);
  }
}

class EserciziTableData extends DataClass
    implements Insertable<EserciziTableData> {
  final int id;
  final String codice;
  final String nome;
  final String descrizione;
  final String istruzioni;
  final String? istruzioniRespirazione;
  final String? noteSicurezza;
  final String? erroriComuni;
  final int idCategoria;
  final int livelloMinimo;
  final int? livelloMassimo;

  /// Codice stabile di [ExerciseImpactLevel].
  final String livelloImpatto;

  /// Intensità cardio: stesso vocabolario di [ExerciseImpactLevel]
  /// (VERY_LOW/LOW/MODERATE/HIGH), non ancora un enum dedicato.
  final String? intensitaCardio;
  final bool richiedeEquilibrio;
  final bool richiedePavimento;
  final bool richiedePosizioneEretta;
  final bool supportoConsentito;
  final int? seriePredefinite;
  final int? ripetizioniPredefinite;
  final int? durataPredefinitaSecondi;
  final int? recuperoPredefinitoSecondi;
  final bool esercizioSistema;
  final bool attivo;
  final int versioneCatalogo;
  final DateTime dataCreazione;
  final DateTime dataModifica;
  const EserciziTableData({
    required this.id,
    required this.codice,
    required this.nome,
    required this.descrizione,
    required this.istruzioni,
    this.istruzioniRespirazione,
    this.noteSicurezza,
    this.erroriComuni,
    required this.idCategoria,
    required this.livelloMinimo,
    this.livelloMassimo,
    required this.livelloImpatto,
    this.intensitaCardio,
    required this.richiedeEquilibrio,
    required this.richiedePavimento,
    required this.richiedePosizioneEretta,
    required this.supportoConsentito,
    this.seriePredefinite,
    this.ripetizioniPredefinite,
    this.durataPredefinitaSecondi,
    this.recuperoPredefinitoSecondi,
    required this.esercizioSistema,
    required this.attivo,
    required this.versioneCatalogo,
    required this.dataCreazione,
    required this.dataModifica,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['codice'] = Variable<String>(codice);
    map['nome'] = Variable<String>(nome);
    map['descrizione'] = Variable<String>(descrizione);
    map['istruzioni'] = Variable<String>(istruzioni);
    if (!nullToAbsent || istruzioniRespirazione != null) {
      map['istruzioni_respirazione'] = Variable<String>(istruzioniRespirazione);
    }
    if (!nullToAbsent || noteSicurezza != null) {
      map['note_sicurezza'] = Variable<String>(noteSicurezza);
    }
    if (!nullToAbsent || erroriComuni != null) {
      map['errori_comuni'] = Variable<String>(erroriComuni);
    }
    map['id_categoria'] = Variable<int>(idCategoria);
    map['livello_minimo'] = Variable<int>(livelloMinimo);
    if (!nullToAbsent || livelloMassimo != null) {
      map['livello_massimo'] = Variable<int>(livelloMassimo);
    }
    map['livello_impatto'] = Variable<String>(livelloImpatto);
    if (!nullToAbsent || intensitaCardio != null) {
      map['intensita_cardio'] = Variable<String>(intensitaCardio);
    }
    map['richiede_equilibrio'] = Variable<bool>(richiedeEquilibrio);
    map['richiede_pavimento'] = Variable<bool>(richiedePavimento);
    map['richiede_posizione_eretta'] = Variable<bool>(richiedePosizioneEretta);
    map['supporto_consentito'] = Variable<bool>(supportoConsentito);
    if (!nullToAbsent || seriePredefinite != null) {
      map['serie_predefinite'] = Variable<int>(seriePredefinite);
    }
    if (!nullToAbsent || ripetizioniPredefinite != null) {
      map['ripetizioni_predefinite'] = Variable<int>(ripetizioniPredefinite);
    }
    if (!nullToAbsent || durataPredefinitaSecondi != null) {
      map['durata_predefinita_secondi'] = Variable<int>(
        durataPredefinitaSecondi,
      );
    }
    if (!nullToAbsent || recuperoPredefinitoSecondi != null) {
      map['recupero_predefinito_secondi'] = Variable<int>(
        recuperoPredefinitoSecondi,
      );
    }
    map['esercizio_sistema'] = Variable<bool>(esercizioSistema);
    map['attivo'] = Variable<bool>(attivo);
    map['versione_catalogo'] = Variable<int>(versioneCatalogo);
    map['data_creazione'] = Variable<DateTime>(dataCreazione);
    map['data_modifica'] = Variable<DateTime>(dataModifica);
    return map;
  }

  EserciziTableCompanion toCompanion(bool nullToAbsent) {
    return EserciziTableCompanion(
      id: Value(id),
      codice: Value(codice),
      nome: Value(nome),
      descrizione: Value(descrizione),
      istruzioni: Value(istruzioni),
      istruzioniRespirazione: istruzioniRespirazione == null && nullToAbsent
          ? const Value.absent()
          : Value(istruzioniRespirazione),
      noteSicurezza: noteSicurezza == null && nullToAbsent
          ? const Value.absent()
          : Value(noteSicurezza),
      erroriComuni: erroriComuni == null && nullToAbsent
          ? const Value.absent()
          : Value(erroriComuni),
      idCategoria: Value(idCategoria),
      livelloMinimo: Value(livelloMinimo),
      livelloMassimo: livelloMassimo == null && nullToAbsent
          ? const Value.absent()
          : Value(livelloMassimo),
      livelloImpatto: Value(livelloImpatto),
      intensitaCardio: intensitaCardio == null && nullToAbsent
          ? const Value.absent()
          : Value(intensitaCardio),
      richiedeEquilibrio: Value(richiedeEquilibrio),
      richiedePavimento: Value(richiedePavimento),
      richiedePosizioneEretta: Value(richiedePosizioneEretta),
      supportoConsentito: Value(supportoConsentito),
      seriePredefinite: seriePredefinite == null && nullToAbsent
          ? const Value.absent()
          : Value(seriePredefinite),
      ripetizioniPredefinite: ripetizioniPredefinite == null && nullToAbsent
          ? const Value.absent()
          : Value(ripetizioniPredefinite),
      durataPredefinitaSecondi: durataPredefinitaSecondi == null && nullToAbsent
          ? const Value.absent()
          : Value(durataPredefinitaSecondi),
      recuperoPredefinitoSecondi:
          recuperoPredefinitoSecondi == null && nullToAbsent
          ? const Value.absent()
          : Value(recuperoPredefinitoSecondi),
      esercizioSistema: Value(esercizioSistema),
      attivo: Value(attivo),
      versioneCatalogo: Value(versioneCatalogo),
      dataCreazione: Value(dataCreazione),
      dataModifica: Value(dataModifica),
    );
  }

  factory EserciziTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EserciziTableData(
      id: serializer.fromJson<int>(json['id']),
      codice: serializer.fromJson<String>(json['codice']),
      nome: serializer.fromJson<String>(json['nome']),
      descrizione: serializer.fromJson<String>(json['descrizione']),
      istruzioni: serializer.fromJson<String>(json['istruzioni']),
      istruzioniRespirazione: serializer.fromJson<String?>(
        json['istruzioniRespirazione'],
      ),
      noteSicurezza: serializer.fromJson<String?>(json['noteSicurezza']),
      erroriComuni: serializer.fromJson<String?>(json['erroriComuni']),
      idCategoria: serializer.fromJson<int>(json['idCategoria']),
      livelloMinimo: serializer.fromJson<int>(json['livelloMinimo']),
      livelloMassimo: serializer.fromJson<int?>(json['livelloMassimo']),
      livelloImpatto: serializer.fromJson<String>(json['livelloImpatto']),
      intensitaCardio: serializer.fromJson<String?>(json['intensitaCardio']),
      richiedeEquilibrio: serializer.fromJson<bool>(json['richiedeEquilibrio']),
      richiedePavimento: serializer.fromJson<bool>(json['richiedePavimento']),
      richiedePosizioneEretta: serializer.fromJson<bool>(
        json['richiedePosizioneEretta'],
      ),
      supportoConsentito: serializer.fromJson<bool>(json['supportoConsentito']),
      seriePredefinite: serializer.fromJson<int?>(json['seriePredefinite']),
      ripetizioniPredefinite: serializer.fromJson<int?>(
        json['ripetizioniPredefinite'],
      ),
      durataPredefinitaSecondi: serializer.fromJson<int?>(
        json['durataPredefinitaSecondi'],
      ),
      recuperoPredefinitoSecondi: serializer.fromJson<int?>(
        json['recuperoPredefinitoSecondi'],
      ),
      esercizioSistema: serializer.fromJson<bool>(json['esercizioSistema']),
      attivo: serializer.fromJson<bool>(json['attivo']),
      versioneCatalogo: serializer.fromJson<int>(json['versioneCatalogo']),
      dataCreazione: serializer.fromJson<DateTime>(json['dataCreazione']),
      dataModifica: serializer.fromJson<DateTime>(json['dataModifica']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'codice': serializer.toJson<String>(codice),
      'nome': serializer.toJson<String>(nome),
      'descrizione': serializer.toJson<String>(descrizione),
      'istruzioni': serializer.toJson<String>(istruzioni),
      'istruzioniRespirazione': serializer.toJson<String?>(
        istruzioniRespirazione,
      ),
      'noteSicurezza': serializer.toJson<String?>(noteSicurezza),
      'erroriComuni': serializer.toJson<String?>(erroriComuni),
      'idCategoria': serializer.toJson<int>(idCategoria),
      'livelloMinimo': serializer.toJson<int>(livelloMinimo),
      'livelloMassimo': serializer.toJson<int?>(livelloMassimo),
      'livelloImpatto': serializer.toJson<String>(livelloImpatto),
      'intensitaCardio': serializer.toJson<String?>(intensitaCardio),
      'richiedeEquilibrio': serializer.toJson<bool>(richiedeEquilibrio),
      'richiedePavimento': serializer.toJson<bool>(richiedePavimento),
      'richiedePosizioneEretta': serializer.toJson<bool>(
        richiedePosizioneEretta,
      ),
      'supportoConsentito': serializer.toJson<bool>(supportoConsentito),
      'seriePredefinite': serializer.toJson<int?>(seriePredefinite),
      'ripetizioniPredefinite': serializer.toJson<int?>(ripetizioniPredefinite),
      'durataPredefinitaSecondi': serializer.toJson<int?>(
        durataPredefinitaSecondi,
      ),
      'recuperoPredefinitoSecondi': serializer.toJson<int?>(
        recuperoPredefinitoSecondi,
      ),
      'esercizioSistema': serializer.toJson<bool>(esercizioSistema),
      'attivo': serializer.toJson<bool>(attivo),
      'versioneCatalogo': serializer.toJson<int>(versioneCatalogo),
      'dataCreazione': serializer.toJson<DateTime>(dataCreazione),
      'dataModifica': serializer.toJson<DateTime>(dataModifica),
    };
  }

  EserciziTableData copyWith({
    int? id,
    String? codice,
    String? nome,
    String? descrizione,
    String? istruzioni,
    Value<String?> istruzioniRespirazione = const Value.absent(),
    Value<String?> noteSicurezza = const Value.absent(),
    Value<String?> erroriComuni = const Value.absent(),
    int? idCategoria,
    int? livelloMinimo,
    Value<int?> livelloMassimo = const Value.absent(),
    String? livelloImpatto,
    Value<String?> intensitaCardio = const Value.absent(),
    bool? richiedeEquilibrio,
    bool? richiedePavimento,
    bool? richiedePosizioneEretta,
    bool? supportoConsentito,
    Value<int?> seriePredefinite = const Value.absent(),
    Value<int?> ripetizioniPredefinite = const Value.absent(),
    Value<int?> durataPredefinitaSecondi = const Value.absent(),
    Value<int?> recuperoPredefinitoSecondi = const Value.absent(),
    bool? esercizioSistema,
    bool? attivo,
    int? versioneCatalogo,
    DateTime? dataCreazione,
    DateTime? dataModifica,
  }) => EserciziTableData(
    id: id ?? this.id,
    codice: codice ?? this.codice,
    nome: nome ?? this.nome,
    descrizione: descrizione ?? this.descrizione,
    istruzioni: istruzioni ?? this.istruzioni,
    istruzioniRespirazione: istruzioniRespirazione.present
        ? istruzioniRespirazione.value
        : this.istruzioniRespirazione,
    noteSicurezza: noteSicurezza.present
        ? noteSicurezza.value
        : this.noteSicurezza,
    erroriComuni: erroriComuni.present ? erroriComuni.value : this.erroriComuni,
    idCategoria: idCategoria ?? this.idCategoria,
    livelloMinimo: livelloMinimo ?? this.livelloMinimo,
    livelloMassimo: livelloMassimo.present
        ? livelloMassimo.value
        : this.livelloMassimo,
    livelloImpatto: livelloImpatto ?? this.livelloImpatto,
    intensitaCardio: intensitaCardio.present
        ? intensitaCardio.value
        : this.intensitaCardio,
    richiedeEquilibrio: richiedeEquilibrio ?? this.richiedeEquilibrio,
    richiedePavimento: richiedePavimento ?? this.richiedePavimento,
    richiedePosizioneEretta:
        richiedePosizioneEretta ?? this.richiedePosizioneEretta,
    supportoConsentito: supportoConsentito ?? this.supportoConsentito,
    seriePredefinite: seriePredefinite.present
        ? seriePredefinite.value
        : this.seriePredefinite,
    ripetizioniPredefinite: ripetizioniPredefinite.present
        ? ripetizioniPredefinite.value
        : this.ripetizioniPredefinite,
    durataPredefinitaSecondi: durataPredefinitaSecondi.present
        ? durataPredefinitaSecondi.value
        : this.durataPredefinitaSecondi,
    recuperoPredefinitoSecondi: recuperoPredefinitoSecondi.present
        ? recuperoPredefinitoSecondi.value
        : this.recuperoPredefinitoSecondi,
    esercizioSistema: esercizioSistema ?? this.esercizioSistema,
    attivo: attivo ?? this.attivo,
    versioneCatalogo: versioneCatalogo ?? this.versioneCatalogo,
    dataCreazione: dataCreazione ?? this.dataCreazione,
    dataModifica: dataModifica ?? this.dataModifica,
  );
  EserciziTableData copyWithCompanion(EserciziTableCompanion data) {
    return EserciziTableData(
      id: data.id.present ? data.id.value : this.id,
      codice: data.codice.present ? data.codice.value : this.codice,
      nome: data.nome.present ? data.nome.value : this.nome,
      descrizione: data.descrizione.present
          ? data.descrizione.value
          : this.descrizione,
      istruzioni: data.istruzioni.present
          ? data.istruzioni.value
          : this.istruzioni,
      istruzioniRespirazione: data.istruzioniRespirazione.present
          ? data.istruzioniRespirazione.value
          : this.istruzioniRespirazione,
      noteSicurezza: data.noteSicurezza.present
          ? data.noteSicurezza.value
          : this.noteSicurezza,
      erroriComuni: data.erroriComuni.present
          ? data.erroriComuni.value
          : this.erroriComuni,
      idCategoria: data.idCategoria.present
          ? data.idCategoria.value
          : this.idCategoria,
      livelloMinimo: data.livelloMinimo.present
          ? data.livelloMinimo.value
          : this.livelloMinimo,
      livelloMassimo: data.livelloMassimo.present
          ? data.livelloMassimo.value
          : this.livelloMassimo,
      livelloImpatto: data.livelloImpatto.present
          ? data.livelloImpatto.value
          : this.livelloImpatto,
      intensitaCardio: data.intensitaCardio.present
          ? data.intensitaCardio.value
          : this.intensitaCardio,
      richiedeEquilibrio: data.richiedeEquilibrio.present
          ? data.richiedeEquilibrio.value
          : this.richiedeEquilibrio,
      richiedePavimento: data.richiedePavimento.present
          ? data.richiedePavimento.value
          : this.richiedePavimento,
      richiedePosizioneEretta: data.richiedePosizioneEretta.present
          ? data.richiedePosizioneEretta.value
          : this.richiedePosizioneEretta,
      supportoConsentito: data.supportoConsentito.present
          ? data.supportoConsentito.value
          : this.supportoConsentito,
      seriePredefinite: data.seriePredefinite.present
          ? data.seriePredefinite.value
          : this.seriePredefinite,
      ripetizioniPredefinite: data.ripetizioniPredefinite.present
          ? data.ripetizioniPredefinite.value
          : this.ripetizioniPredefinite,
      durataPredefinitaSecondi: data.durataPredefinitaSecondi.present
          ? data.durataPredefinitaSecondi.value
          : this.durataPredefinitaSecondi,
      recuperoPredefinitoSecondi: data.recuperoPredefinitoSecondi.present
          ? data.recuperoPredefinitoSecondi.value
          : this.recuperoPredefinitoSecondi,
      esercizioSistema: data.esercizioSistema.present
          ? data.esercizioSistema.value
          : this.esercizioSistema,
      attivo: data.attivo.present ? data.attivo.value : this.attivo,
      versioneCatalogo: data.versioneCatalogo.present
          ? data.versioneCatalogo.value
          : this.versioneCatalogo,
      dataCreazione: data.dataCreazione.present
          ? data.dataCreazione.value
          : this.dataCreazione,
      dataModifica: data.dataModifica.present
          ? data.dataModifica.value
          : this.dataModifica,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EserciziTableData(')
          ..write('id: $id, ')
          ..write('codice: $codice, ')
          ..write('nome: $nome, ')
          ..write('descrizione: $descrizione, ')
          ..write('istruzioni: $istruzioni, ')
          ..write('istruzioniRespirazione: $istruzioniRespirazione, ')
          ..write('noteSicurezza: $noteSicurezza, ')
          ..write('erroriComuni: $erroriComuni, ')
          ..write('idCategoria: $idCategoria, ')
          ..write('livelloMinimo: $livelloMinimo, ')
          ..write('livelloMassimo: $livelloMassimo, ')
          ..write('livelloImpatto: $livelloImpatto, ')
          ..write('intensitaCardio: $intensitaCardio, ')
          ..write('richiedeEquilibrio: $richiedeEquilibrio, ')
          ..write('richiedePavimento: $richiedePavimento, ')
          ..write('richiedePosizioneEretta: $richiedePosizioneEretta, ')
          ..write('supportoConsentito: $supportoConsentito, ')
          ..write('seriePredefinite: $seriePredefinite, ')
          ..write('ripetizioniPredefinite: $ripetizioniPredefinite, ')
          ..write('durataPredefinitaSecondi: $durataPredefinitaSecondi, ')
          ..write('recuperoPredefinitoSecondi: $recuperoPredefinitoSecondi, ')
          ..write('esercizioSistema: $esercizioSistema, ')
          ..write('attivo: $attivo, ')
          ..write('versioneCatalogo: $versioneCatalogo, ')
          ..write('dataCreazione: $dataCreazione, ')
          ..write('dataModifica: $dataModifica')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    codice,
    nome,
    descrizione,
    istruzioni,
    istruzioniRespirazione,
    noteSicurezza,
    erroriComuni,
    idCategoria,
    livelloMinimo,
    livelloMassimo,
    livelloImpatto,
    intensitaCardio,
    richiedeEquilibrio,
    richiedePavimento,
    richiedePosizioneEretta,
    supportoConsentito,
    seriePredefinite,
    ripetizioniPredefinite,
    durataPredefinitaSecondi,
    recuperoPredefinitoSecondi,
    esercizioSistema,
    attivo,
    versioneCatalogo,
    dataCreazione,
    dataModifica,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EserciziTableData &&
          other.id == this.id &&
          other.codice == this.codice &&
          other.nome == this.nome &&
          other.descrizione == this.descrizione &&
          other.istruzioni == this.istruzioni &&
          other.istruzioniRespirazione == this.istruzioniRespirazione &&
          other.noteSicurezza == this.noteSicurezza &&
          other.erroriComuni == this.erroriComuni &&
          other.idCategoria == this.idCategoria &&
          other.livelloMinimo == this.livelloMinimo &&
          other.livelloMassimo == this.livelloMassimo &&
          other.livelloImpatto == this.livelloImpatto &&
          other.intensitaCardio == this.intensitaCardio &&
          other.richiedeEquilibrio == this.richiedeEquilibrio &&
          other.richiedePavimento == this.richiedePavimento &&
          other.richiedePosizioneEretta == this.richiedePosizioneEretta &&
          other.supportoConsentito == this.supportoConsentito &&
          other.seriePredefinite == this.seriePredefinite &&
          other.ripetizioniPredefinite == this.ripetizioniPredefinite &&
          other.durataPredefinitaSecondi == this.durataPredefinitaSecondi &&
          other.recuperoPredefinitoSecondi == this.recuperoPredefinitoSecondi &&
          other.esercizioSistema == this.esercizioSistema &&
          other.attivo == this.attivo &&
          other.versioneCatalogo == this.versioneCatalogo &&
          other.dataCreazione == this.dataCreazione &&
          other.dataModifica == this.dataModifica);
}

class EserciziTableCompanion extends UpdateCompanion<EserciziTableData> {
  final Value<int> id;
  final Value<String> codice;
  final Value<String> nome;
  final Value<String> descrizione;
  final Value<String> istruzioni;
  final Value<String?> istruzioniRespirazione;
  final Value<String?> noteSicurezza;
  final Value<String?> erroriComuni;
  final Value<int> idCategoria;
  final Value<int> livelloMinimo;
  final Value<int?> livelloMassimo;
  final Value<String> livelloImpatto;
  final Value<String?> intensitaCardio;
  final Value<bool> richiedeEquilibrio;
  final Value<bool> richiedePavimento;
  final Value<bool> richiedePosizioneEretta;
  final Value<bool> supportoConsentito;
  final Value<int?> seriePredefinite;
  final Value<int?> ripetizioniPredefinite;
  final Value<int?> durataPredefinitaSecondi;
  final Value<int?> recuperoPredefinitoSecondi;
  final Value<bool> esercizioSistema;
  final Value<bool> attivo;
  final Value<int> versioneCatalogo;
  final Value<DateTime> dataCreazione;
  final Value<DateTime> dataModifica;
  const EserciziTableCompanion({
    this.id = const Value.absent(),
    this.codice = const Value.absent(),
    this.nome = const Value.absent(),
    this.descrizione = const Value.absent(),
    this.istruzioni = const Value.absent(),
    this.istruzioniRespirazione = const Value.absent(),
    this.noteSicurezza = const Value.absent(),
    this.erroriComuni = const Value.absent(),
    this.idCategoria = const Value.absent(),
    this.livelloMinimo = const Value.absent(),
    this.livelloMassimo = const Value.absent(),
    this.livelloImpatto = const Value.absent(),
    this.intensitaCardio = const Value.absent(),
    this.richiedeEquilibrio = const Value.absent(),
    this.richiedePavimento = const Value.absent(),
    this.richiedePosizioneEretta = const Value.absent(),
    this.supportoConsentito = const Value.absent(),
    this.seriePredefinite = const Value.absent(),
    this.ripetizioniPredefinite = const Value.absent(),
    this.durataPredefinitaSecondi = const Value.absent(),
    this.recuperoPredefinitoSecondi = const Value.absent(),
    this.esercizioSistema = const Value.absent(),
    this.attivo = const Value.absent(),
    this.versioneCatalogo = const Value.absent(),
    this.dataCreazione = const Value.absent(),
    this.dataModifica = const Value.absent(),
  });
  EserciziTableCompanion.insert({
    this.id = const Value.absent(),
    required String codice,
    required String nome,
    required String descrizione,
    required String istruzioni,
    this.istruzioniRespirazione = const Value.absent(),
    this.noteSicurezza = const Value.absent(),
    this.erroriComuni = const Value.absent(),
    required int idCategoria,
    required int livelloMinimo,
    this.livelloMassimo = const Value.absent(),
    required String livelloImpatto,
    this.intensitaCardio = const Value.absent(),
    this.richiedeEquilibrio = const Value.absent(),
    this.richiedePavimento = const Value.absent(),
    this.richiedePosizioneEretta = const Value.absent(),
    this.supportoConsentito = const Value.absent(),
    this.seriePredefinite = const Value.absent(),
    this.ripetizioniPredefinite = const Value.absent(),
    this.durataPredefinitaSecondi = const Value.absent(),
    this.recuperoPredefinitoSecondi = const Value.absent(),
    this.esercizioSistema = const Value.absent(),
    this.attivo = const Value.absent(),
    required int versioneCatalogo,
    required DateTime dataCreazione,
    required DateTime dataModifica,
  }) : codice = Value(codice),
       nome = Value(nome),
       descrizione = Value(descrizione),
       istruzioni = Value(istruzioni),
       idCategoria = Value(idCategoria),
       livelloMinimo = Value(livelloMinimo),
       livelloImpatto = Value(livelloImpatto),
       versioneCatalogo = Value(versioneCatalogo),
       dataCreazione = Value(dataCreazione),
       dataModifica = Value(dataModifica);
  static Insertable<EserciziTableData> custom({
    Expression<int>? id,
    Expression<String>? codice,
    Expression<String>? nome,
    Expression<String>? descrizione,
    Expression<String>? istruzioni,
    Expression<String>? istruzioniRespirazione,
    Expression<String>? noteSicurezza,
    Expression<String>? erroriComuni,
    Expression<int>? idCategoria,
    Expression<int>? livelloMinimo,
    Expression<int>? livelloMassimo,
    Expression<String>? livelloImpatto,
    Expression<String>? intensitaCardio,
    Expression<bool>? richiedeEquilibrio,
    Expression<bool>? richiedePavimento,
    Expression<bool>? richiedePosizioneEretta,
    Expression<bool>? supportoConsentito,
    Expression<int>? seriePredefinite,
    Expression<int>? ripetizioniPredefinite,
    Expression<int>? durataPredefinitaSecondi,
    Expression<int>? recuperoPredefinitoSecondi,
    Expression<bool>? esercizioSistema,
    Expression<bool>? attivo,
    Expression<int>? versioneCatalogo,
    Expression<DateTime>? dataCreazione,
    Expression<DateTime>? dataModifica,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (codice != null) 'codice': codice,
      if (nome != null) 'nome': nome,
      if (descrizione != null) 'descrizione': descrizione,
      if (istruzioni != null) 'istruzioni': istruzioni,
      if (istruzioniRespirazione != null)
        'istruzioni_respirazione': istruzioniRespirazione,
      if (noteSicurezza != null) 'note_sicurezza': noteSicurezza,
      if (erroriComuni != null) 'errori_comuni': erroriComuni,
      if (idCategoria != null) 'id_categoria': idCategoria,
      if (livelloMinimo != null) 'livello_minimo': livelloMinimo,
      if (livelloMassimo != null) 'livello_massimo': livelloMassimo,
      if (livelloImpatto != null) 'livello_impatto': livelloImpatto,
      if (intensitaCardio != null) 'intensita_cardio': intensitaCardio,
      if (richiedeEquilibrio != null) 'richiede_equilibrio': richiedeEquilibrio,
      if (richiedePavimento != null) 'richiede_pavimento': richiedePavimento,
      if (richiedePosizioneEretta != null)
        'richiede_posizione_eretta': richiedePosizioneEretta,
      if (supportoConsentito != null) 'supporto_consentito': supportoConsentito,
      if (seriePredefinite != null) 'serie_predefinite': seriePredefinite,
      if (ripetizioniPredefinite != null)
        'ripetizioni_predefinite': ripetizioniPredefinite,
      if (durataPredefinitaSecondi != null)
        'durata_predefinita_secondi': durataPredefinitaSecondi,
      if (recuperoPredefinitoSecondi != null)
        'recupero_predefinito_secondi': recuperoPredefinitoSecondi,
      if (esercizioSistema != null) 'esercizio_sistema': esercizioSistema,
      if (attivo != null) 'attivo': attivo,
      if (versioneCatalogo != null) 'versione_catalogo': versioneCatalogo,
      if (dataCreazione != null) 'data_creazione': dataCreazione,
      if (dataModifica != null) 'data_modifica': dataModifica,
    });
  }

  EserciziTableCompanion copyWith({
    Value<int>? id,
    Value<String>? codice,
    Value<String>? nome,
    Value<String>? descrizione,
    Value<String>? istruzioni,
    Value<String?>? istruzioniRespirazione,
    Value<String?>? noteSicurezza,
    Value<String?>? erroriComuni,
    Value<int>? idCategoria,
    Value<int>? livelloMinimo,
    Value<int?>? livelloMassimo,
    Value<String>? livelloImpatto,
    Value<String?>? intensitaCardio,
    Value<bool>? richiedeEquilibrio,
    Value<bool>? richiedePavimento,
    Value<bool>? richiedePosizioneEretta,
    Value<bool>? supportoConsentito,
    Value<int?>? seriePredefinite,
    Value<int?>? ripetizioniPredefinite,
    Value<int?>? durataPredefinitaSecondi,
    Value<int?>? recuperoPredefinitoSecondi,
    Value<bool>? esercizioSistema,
    Value<bool>? attivo,
    Value<int>? versioneCatalogo,
    Value<DateTime>? dataCreazione,
    Value<DateTime>? dataModifica,
  }) {
    return EserciziTableCompanion(
      id: id ?? this.id,
      codice: codice ?? this.codice,
      nome: nome ?? this.nome,
      descrizione: descrizione ?? this.descrizione,
      istruzioni: istruzioni ?? this.istruzioni,
      istruzioniRespirazione:
          istruzioniRespirazione ?? this.istruzioniRespirazione,
      noteSicurezza: noteSicurezza ?? this.noteSicurezza,
      erroriComuni: erroriComuni ?? this.erroriComuni,
      idCategoria: idCategoria ?? this.idCategoria,
      livelloMinimo: livelloMinimo ?? this.livelloMinimo,
      livelloMassimo: livelloMassimo ?? this.livelloMassimo,
      livelloImpatto: livelloImpatto ?? this.livelloImpatto,
      intensitaCardio: intensitaCardio ?? this.intensitaCardio,
      richiedeEquilibrio: richiedeEquilibrio ?? this.richiedeEquilibrio,
      richiedePavimento: richiedePavimento ?? this.richiedePavimento,
      richiedePosizioneEretta:
          richiedePosizioneEretta ?? this.richiedePosizioneEretta,
      supportoConsentito: supportoConsentito ?? this.supportoConsentito,
      seriePredefinite: seriePredefinite ?? this.seriePredefinite,
      ripetizioniPredefinite:
          ripetizioniPredefinite ?? this.ripetizioniPredefinite,
      durataPredefinitaSecondi:
          durataPredefinitaSecondi ?? this.durataPredefinitaSecondi,
      recuperoPredefinitoSecondi:
          recuperoPredefinitoSecondi ?? this.recuperoPredefinitoSecondi,
      esercizioSistema: esercizioSistema ?? this.esercizioSistema,
      attivo: attivo ?? this.attivo,
      versioneCatalogo: versioneCatalogo ?? this.versioneCatalogo,
      dataCreazione: dataCreazione ?? this.dataCreazione,
      dataModifica: dataModifica ?? this.dataModifica,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (codice.present) {
      map['codice'] = Variable<String>(codice.value);
    }
    if (nome.present) {
      map['nome'] = Variable<String>(nome.value);
    }
    if (descrizione.present) {
      map['descrizione'] = Variable<String>(descrizione.value);
    }
    if (istruzioni.present) {
      map['istruzioni'] = Variable<String>(istruzioni.value);
    }
    if (istruzioniRespirazione.present) {
      map['istruzioni_respirazione'] = Variable<String>(
        istruzioniRespirazione.value,
      );
    }
    if (noteSicurezza.present) {
      map['note_sicurezza'] = Variable<String>(noteSicurezza.value);
    }
    if (erroriComuni.present) {
      map['errori_comuni'] = Variable<String>(erroriComuni.value);
    }
    if (idCategoria.present) {
      map['id_categoria'] = Variable<int>(idCategoria.value);
    }
    if (livelloMinimo.present) {
      map['livello_minimo'] = Variable<int>(livelloMinimo.value);
    }
    if (livelloMassimo.present) {
      map['livello_massimo'] = Variable<int>(livelloMassimo.value);
    }
    if (livelloImpatto.present) {
      map['livello_impatto'] = Variable<String>(livelloImpatto.value);
    }
    if (intensitaCardio.present) {
      map['intensita_cardio'] = Variable<String>(intensitaCardio.value);
    }
    if (richiedeEquilibrio.present) {
      map['richiede_equilibrio'] = Variable<bool>(richiedeEquilibrio.value);
    }
    if (richiedePavimento.present) {
      map['richiede_pavimento'] = Variable<bool>(richiedePavimento.value);
    }
    if (richiedePosizioneEretta.present) {
      map['richiede_posizione_eretta'] = Variable<bool>(
        richiedePosizioneEretta.value,
      );
    }
    if (supportoConsentito.present) {
      map['supporto_consentito'] = Variable<bool>(supportoConsentito.value);
    }
    if (seriePredefinite.present) {
      map['serie_predefinite'] = Variable<int>(seriePredefinite.value);
    }
    if (ripetizioniPredefinite.present) {
      map['ripetizioni_predefinite'] = Variable<int>(
        ripetizioniPredefinite.value,
      );
    }
    if (durataPredefinitaSecondi.present) {
      map['durata_predefinita_secondi'] = Variable<int>(
        durataPredefinitaSecondi.value,
      );
    }
    if (recuperoPredefinitoSecondi.present) {
      map['recupero_predefinito_secondi'] = Variable<int>(
        recuperoPredefinitoSecondi.value,
      );
    }
    if (esercizioSistema.present) {
      map['esercizio_sistema'] = Variable<bool>(esercizioSistema.value);
    }
    if (attivo.present) {
      map['attivo'] = Variable<bool>(attivo.value);
    }
    if (versioneCatalogo.present) {
      map['versione_catalogo'] = Variable<int>(versioneCatalogo.value);
    }
    if (dataCreazione.present) {
      map['data_creazione'] = Variable<DateTime>(dataCreazione.value);
    }
    if (dataModifica.present) {
      map['data_modifica'] = Variable<DateTime>(dataModifica.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EserciziTableCompanion(')
          ..write('id: $id, ')
          ..write('codice: $codice, ')
          ..write('nome: $nome, ')
          ..write('descrizione: $descrizione, ')
          ..write('istruzioni: $istruzioni, ')
          ..write('istruzioniRespirazione: $istruzioniRespirazione, ')
          ..write('noteSicurezza: $noteSicurezza, ')
          ..write('erroriComuni: $erroriComuni, ')
          ..write('idCategoria: $idCategoria, ')
          ..write('livelloMinimo: $livelloMinimo, ')
          ..write('livelloMassimo: $livelloMassimo, ')
          ..write('livelloImpatto: $livelloImpatto, ')
          ..write('intensitaCardio: $intensitaCardio, ')
          ..write('richiedeEquilibrio: $richiedeEquilibrio, ')
          ..write('richiedePavimento: $richiedePavimento, ')
          ..write('richiedePosizioneEretta: $richiedePosizioneEretta, ')
          ..write('supportoConsentito: $supportoConsentito, ')
          ..write('seriePredefinite: $seriePredefinite, ')
          ..write('ripetizioniPredefinite: $ripetizioniPredefinite, ')
          ..write('durataPredefinitaSecondi: $durataPredefinitaSecondi, ')
          ..write('recuperoPredefinitoSecondi: $recuperoPredefinitoSecondi, ')
          ..write('esercizioSistema: $esercizioSistema, ')
          ..write('attivo: $attivo, ')
          ..write('versioneCatalogo: $versioneCatalogo, ')
          ..write('dataCreazione: $dataCreazione, ')
          ..write('dataModifica: $dataModifica')
          ..write(')'))
        .toString();
  }
}

class $EserciziGruppiMuscolariTableTable extends EserciziGruppiMuscolariTable
    with
        TableInfo<
          $EserciziGruppiMuscolariTableTable,
          EserciziGruppiMuscolariTableData
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EserciziGruppiMuscolariTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _idEsercizioMeta = const VerificationMeta(
    'idEsercizio',
  );
  @override
  late final GeneratedColumn<int> idEsercizio = GeneratedColumn<int>(
    'id_esercizio',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES esercizi (id)',
    ),
  );
  static const VerificationMeta _idGruppoMuscolareMeta = const VerificationMeta(
    'idGruppoMuscolare',
  );
  @override
  late final GeneratedColumn<int> idGruppoMuscolare = GeneratedColumn<int>(
    'id_gruppo_muscolare',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES gruppi_muscolari (id)',
    ),
  );
  static const VerificationMeta _tipoCoinvolgimentoMeta =
      const VerificationMeta('tipoCoinvolgimento');
  @override
  late final GeneratedColumn<String> tipoCoinvolgimento =
      GeneratedColumn<String>(
        'tipo_coinvolgimento',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    idEsercizio,
    idGruppoMuscolare,
    tipoCoinvolgimento,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'esercizi_gruppi_muscolari';
  @override
  VerificationContext validateIntegrity(
    Insertable<EserciziGruppiMuscolariTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('id_esercizio')) {
      context.handle(
        _idEsercizioMeta,
        idEsercizio.isAcceptableOrUnknown(
          data['id_esercizio']!,
          _idEsercizioMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_idEsercizioMeta);
    }
    if (data.containsKey('id_gruppo_muscolare')) {
      context.handle(
        _idGruppoMuscolareMeta,
        idGruppoMuscolare.isAcceptableOrUnknown(
          data['id_gruppo_muscolare']!,
          _idGruppoMuscolareMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_idGruppoMuscolareMeta);
    }
    if (data.containsKey('tipo_coinvolgimento')) {
      context.handle(
        _tipoCoinvolgimentoMeta,
        tipoCoinvolgimento.isAcceptableOrUnknown(
          data['tipo_coinvolgimento']!,
          _tipoCoinvolgimentoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_tipoCoinvolgimentoMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {idEsercizio, idGruppoMuscolare},
  ];
  @override
  EserciziGruppiMuscolariTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EserciziGruppiMuscolariTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      idEsercizio: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id_esercizio'],
      )!,
      idGruppoMuscolare: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id_gruppo_muscolare'],
      )!,
      tipoCoinvolgimento: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tipo_coinvolgimento'],
      )!,
    );
  }

  @override
  $EserciziGruppiMuscolariTableTable createAlias(String alias) {
    return $EserciziGruppiMuscolariTableTable(attachedDatabase, alias);
  }
}

class EserciziGruppiMuscolariTableData extends DataClass
    implements Insertable<EserciziGruppiMuscolariTableData> {
  final int id;
  final int idEsercizio;
  final int idGruppoMuscolare;

  /// Codice stabile di [ExerciseMuscleRole].
  final String tipoCoinvolgimento;
  const EserciziGruppiMuscolariTableData({
    required this.id,
    required this.idEsercizio,
    required this.idGruppoMuscolare,
    required this.tipoCoinvolgimento,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['id_esercizio'] = Variable<int>(idEsercizio);
    map['id_gruppo_muscolare'] = Variable<int>(idGruppoMuscolare);
    map['tipo_coinvolgimento'] = Variable<String>(tipoCoinvolgimento);
    return map;
  }

  EserciziGruppiMuscolariTableCompanion toCompanion(bool nullToAbsent) {
    return EserciziGruppiMuscolariTableCompanion(
      id: Value(id),
      idEsercizio: Value(idEsercizio),
      idGruppoMuscolare: Value(idGruppoMuscolare),
      tipoCoinvolgimento: Value(tipoCoinvolgimento),
    );
  }

  factory EserciziGruppiMuscolariTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EserciziGruppiMuscolariTableData(
      id: serializer.fromJson<int>(json['id']),
      idEsercizio: serializer.fromJson<int>(json['idEsercizio']),
      idGruppoMuscolare: serializer.fromJson<int>(json['idGruppoMuscolare']),
      tipoCoinvolgimento: serializer.fromJson<String>(
        json['tipoCoinvolgimento'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'idEsercizio': serializer.toJson<int>(idEsercizio),
      'idGruppoMuscolare': serializer.toJson<int>(idGruppoMuscolare),
      'tipoCoinvolgimento': serializer.toJson<String>(tipoCoinvolgimento),
    };
  }

  EserciziGruppiMuscolariTableData copyWith({
    int? id,
    int? idEsercizio,
    int? idGruppoMuscolare,
    String? tipoCoinvolgimento,
  }) => EserciziGruppiMuscolariTableData(
    id: id ?? this.id,
    idEsercizio: idEsercizio ?? this.idEsercizio,
    idGruppoMuscolare: idGruppoMuscolare ?? this.idGruppoMuscolare,
    tipoCoinvolgimento: tipoCoinvolgimento ?? this.tipoCoinvolgimento,
  );
  EserciziGruppiMuscolariTableData copyWithCompanion(
    EserciziGruppiMuscolariTableCompanion data,
  ) {
    return EserciziGruppiMuscolariTableData(
      id: data.id.present ? data.id.value : this.id,
      idEsercizio: data.idEsercizio.present
          ? data.idEsercizio.value
          : this.idEsercizio,
      idGruppoMuscolare: data.idGruppoMuscolare.present
          ? data.idGruppoMuscolare.value
          : this.idGruppoMuscolare,
      tipoCoinvolgimento: data.tipoCoinvolgimento.present
          ? data.tipoCoinvolgimento.value
          : this.tipoCoinvolgimento,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EserciziGruppiMuscolariTableData(')
          ..write('id: $id, ')
          ..write('idEsercizio: $idEsercizio, ')
          ..write('idGruppoMuscolare: $idGruppoMuscolare, ')
          ..write('tipoCoinvolgimento: $tipoCoinvolgimento')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, idEsercizio, idGruppoMuscolare, tipoCoinvolgimento);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EserciziGruppiMuscolariTableData &&
          other.id == this.id &&
          other.idEsercizio == this.idEsercizio &&
          other.idGruppoMuscolare == this.idGruppoMuscolare &&
          other.tipoCoinvolgimento == this.tipoCoinvolgimento);
}

class EserciziGruppiMuscolariTableCompanion
    extends UpdateCompanion<EserciziGruppiMuscolariTableData> {
  final Value<int> id;
  final Value<int> idEsercizio;
  final Value<int> idGruppoMuscolare;
  final Value<String> tipoCoinvolgimento;
  const EserciziGruppiMuscolariTableCompanion({
    this.id = const Value.absent(),
    this.idEsercizio = const Value.absent(),
    this.idGruppoMuscolare = const Value.absent(),
    this.tipoCoinvolgimento = const Value.absent(),
  });
  EserciziGruppiMuscolariTableCompanion.insert({
    this.id = const Value.absent(),
    required int idEsercizio,
    required int idGruppoMuscolare,
    required String tipoCoinvolgimento,
  }) : idEsercizio = Value(idEsercizio),
       idGruppoMuscolare = Value(idGruppoMuscolare),
       tipoCoinvolgimento = Value(tipoCoinvolgimento);
  static Insertable<EserciziGruppiMuscolariTableData> custom({
    Expression<int>? id,
    Expression<int>? idEsercizio,
    Expression<int>? idGruppoMuscolare,
    Expression<String>? tipoCoinvolgimento,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (idEsercizio != null) 'id_esercizio': idEsercizio,
      if (idGruppoMuscolare != null) 'id_gruppo_muscolare': idGruppoMuscolare,
      if (tipoCoinvolgimento != null) 'tipo_coinvolgimento': tipoCoinvolgimento,
    });
  }

  EserciziGruppiMuscolariTableCompanion copyWith({
    Value<int>? id,
    Value<int>? idEsercizio,
    Value<int>? idGruppoMuscolare,
    Value<String>? tipoCoinvolgimento,
  }) {
    return EserciziGruppiMuscolariTableCompanion(
      id: id ?? this.id,
      idEsercizio: idEsercizio ?? this.idEsercizio,
      idGruppoMuscolare: idGruppoMuscolare ?? this.idGruppoMuscolare,
      tipoCoinvolgimento: tipoCoinvolgimento ?? this.tipoCoinvolgimento,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (idEsercizio.present) {
      map['id_esercizio'] = Variable<int>(idEsercizio.value);
    }
    if (idGruppoMuscolare.present) {
      map['id_gruppo_muscolare'] = Variable<int>(idGruppoMuscolare.value);
    }
    if (tipoCoinvolgimento.present) {
      map['tipo_coinvolgimento'] = Variable<String>(tipoCoinvolgimento.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EserciziGruppiMuscolariTableCompanion(')
          ..write('id: $id, ')
          ..write('idEsercizio: $idEsercizio, ')
          ..write('idGruppoMuscolare: $idGruppoMuscolare, ')
          ..write('tipoCoinvolgimento: $tipoCoinvolgimento')
          ..write(')'))
        .toString();
  }
}

class $AttrezzatureTableTable extends AttrezzatureTable
    with TableInfo<$AttrezzatureTableTable, AttrezzatureTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AttrezzatureTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _codiceMeta = const VerificationMeta('codice');
  @override
  late final GeneratedColumn<String> codice = GeneratedColumn<String>(
    'codice',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _nomeMeta = const VerificationMeta('nome');
  @override
  late final GeneratedColumn<String> nome = GeneratedColumn<String>(
    'nome',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descrizioneMeta = const VerificationMeta(
    'descrizione',
  );
  @override
  late final GeneratedColumn<String> descrizione = GeneratedColumn<String>(
    'descrizione',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoriaMeta = const VerificationMeta(
    'categoria',
  );
  @override
  late final GeneratedColumn<String> categoria = GeneratedColumn<String>(
    'categoria',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _prezzoMinimoIndicativoMeta =
      const VerificationMeta('prezzoMinimoIndicativo');
  @override
  late final GeneratedColumn<double> prezzoMinimoIndicativo =
      GeneratedColumn<double>(
        'prezzo_minimo_indicativo',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _prezzoMassimoIndicativoMeta =
      const VerificationMeta('prezzoMassimoIndicativo');
  @override
  late final GeneratedColumn<double> prezzoMassimoIndicativo =
      GeneratedColumn<double>(
        'prezzo_massimo_indicativo',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _prioritaMeta = const VerificationMeta(
    'priorita',
  );
  @override
  late final GeneratedColumn<int> priorita = GeneratedColumn<int>(
    'priorita',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _queryRicercaMeta = const VerificationMeta(
    'queryRicerca',
  );
  @override
  late final GeneratedColumn<String> queryRicerca = GeneratedColumn<String>(
    'query_ricerca',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _attivaMeta = const VerificationMeta('attiva');
  @override
  late final GeneratedColumn<bool> attiva = GeneratedColumn<bool>(
    'attiva',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("attiva" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _versioneCatalogoMeta = const VerificationMeta(
    'versioneCatalogo',
  );
  @override
  late final GeneratedColumn<int> versioneCatalogo = GeneratedColumn<int>(
    'versione_catalogo',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dataCreazioneMeta = const VerificationMeta(
    'dataCreazione',
  );
  @override
  late final GeneratedColumn<DateTime> dataCreazione =
      GeneratedColumn<DateTime>(
        'data_creazione',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _dataModificaMeta = const VerificationMeta(
    'dataModifica',
  );
  @override
  late final GeneratedColumn<DateTime> dataModifica = GeneratedColumn<DateTime>(
    'data_modifica',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    codice,
    nome,
    descrizione,
    categoria,
    prezzoMinimoIndicativo,
    prezzoMassimoIndicativo,
    priorita,
    queryRicerca,
    attiva,
    versioneCatalogo,
    dataCreazione,
    dataModifica,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attrezzature';
  @override
  VerificationContext validateIntegrity(
    Insertable<AttrezzatureTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('codice')) {
      context.handle(
        _codiceMeta,
        codice.isAcceptableOrUnknown(data['codice']!, _codiceMeta),
      );
    } else if (isInserting) {
      context.missing(_codiceMeta);
    }
    if (data.containsKey('nome')) {
      context.handle(
        _nomeMeta,
        nome.isAcceptableOrUnknown(data['nome']!, _nomeMeta),
      );
    } else if (isInserting) {
      context.missing(_nomeMeta);
    }
    if (data.containsKey('descrizione')) {
      context.handle(
        _descrizioneMeta,
        descrizione.isAcceptableOrUnknown(
          data['descrizione']!,
          _descrizioneMeta,
        ),
      );
    }
    if (data.containsKey('categoria')) {
      context.handle(
        _categoriaMeta,
        categoria.isAcceptableOrUnknown(data['categoria']!, _categoriaMeta),
      );
    }
    if (data.containsKey('prezzo_minimo_indicativo')) {
      context.handle(
        _prezzoMinimoIndicativoMeta,
        prezzoMinimoIndicativo.isAcceptableOrUnknown(
          data['prezzo_minimo_indicativo']!,
          _prezzoMinimoIndicativoMeta,
        ),
      );
    }
    if (data.containsKey('prezzo_massimo_indicativo')) {
      context.handle(
        _prezzoMassimoIndicativoMeta,
        prezzoMassimoIndicativo.isAcceptableOrUnknown(
          data['prezzo_massimo_indicativo']!,
          _prezzoMassimoIndicativoMeta,
        ),
      );
    }
    if (data.containsKey('priorita')) {
      context.handle(
        _prioritaMeta,
        priorita.isAcceptableOrUnknown(data['priorita']!, _prioritaMeta),
      );
    }
    if (data.containsKey('query_ricerca')) {
      context.handle(
        _queryRicercaMeta,
        queryRicerca.isAcceptableOrUnknown(
          data['query_ricerca']!,
          _queryRicercaMeta,
        ),
      );
    }
    if (data.containsKey('attiva')) {
      context.handle(
        _attivaMeta,
        attiva.isAcceptableOrUnknown(data['attiva']!, _attivaMeta),
      );
    }
    if (data.containsKey('versione_catalogo')) {
      context.handle(
        _versioneCatalogoMeta,
        versioneCatalogo.isAcceptableOrUnknown(
          data['versione_catalogo']!,
          _versioneCatalogoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_versioneCatalogoMeta);
    }
    if (data.containsKey('data_creazione')) {
      context.handle(
        _dataCreazioneMeta,
        dataCreazione.isAcceptableOrUnknown(
          data['data_creazione']!,
          _dataCreazioneMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dataCreazioneMeta);
    }
    if (data.containsKey('data_modifica')) {
      context.handle(
        _dataModificaMeta,
        dataModifica.isAcceptableOrUnknown(
          data['data_modifica']!,
          _dataModificaMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dataModificaMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AttrezzatureTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AttrezzatureTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      codice: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}codice'],
      )!,
      nome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nome'],
      )!,
      descrizione: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}descrizione'],
      ),
      categoria: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}categoria'],
      ),
      prezzoMinimoIndicativo: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}prezzo_minimo_indicativo'],
      ),
      prezzoMassimoIndicativo: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}prezzo_massimo_indicativo'],
      ),
      priorita: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}priorita'],
      )!,
      queryRicerca: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}query_ricerca'],
      ),
      attiva: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}attiva'],
      )!,
      versioneCatalogo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}versione_catalogo'],
      )!,
      dataCreazione: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}data_creazione'],
      )!,
      dataModifica: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}data_modifica'],
      )!,
    );
  }

  @override
  $AttrezzatureTableTable createAlias(String alias) {
    return $AttrezzatureTableTable(attachedDatabase, alias);
  }
}

class AttrezzatureTableData extends DataClass
    implements Insertable<AttrezzatureTableData> {
  final int id;
  final String codice;
  final String nome;
  final String? descrizione;
  final String? categoria;
  final double? prezzoMinimoIndicativo;
  final double? prezzoMassimoIndicativo;
  final int priorita;
  final String? queryRicerca;
  final bool attiva;
  final int versioneCatalogo;
  final DateTime dataCreazione;
  final DateTime dataModifica;
  const AttrezzatureTableData({
    required this.id,
    required this.codice,
    required this.nome,
    this.descrizione,
    this.categoria,
    this.prezzoMinimoIndicativo,
    this.prezzoMassimoIndicativo,
    required this.priorita,
    this.queryRicerca,
    required this.attiva,
    required this.versioneCatalogo,
    required this.dataCreazione,
    required this.dataModifica,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['codice'] = Variable<String>(codice);
    map['nome'] = Variable<String>(nome);
    if (!nullToAbsent || descrizione != null) {
      map['descrizione'] = Variable<String>(descrizione);
    }
    if (!nullToAbsent || categoria != null) {
      map['categoria'] = Variable<String>(categoria);
    }
    if (!nullToAbsent || prezzoMinimoIndicativo != null) {
      map['prezzo_minimo_indicativo'] = Variable<double>(
        prezzoMinimoIndicativo,
      );
    }
    if (!nullToAbsent || prezzoMassimoIndicativo != null) {
      map['prezzo_massimo_indicativo'] = Variable<double>(
        prezzoMassimoIndicativo,
      );
    }
    map['priorita'] = Variable<int>(priorita);
    if (!nullToAbsent || queryRicerca != null) {
      map['query_ricerca'] = Variable<String>(queryRicerca);
    }
    map['attiva'] = Variable<bool>(attiva);
    map['versione_catalogo'] = Variable<int>(versioneCatalogo);
    map['data_creazione'] = Variable<DateTime>(dataCreazione);
    map['data_modifica'] = Variable<DateTime>(dataModifica);
    return map;
  }

  AttrezzatureTableCompanion toCompanion(bool nullToAbsent) {
    return AttrezzatureTableCompanion(
      id: Value(id),
      codice: Value(codice),
      nome: Value(nome),
      descrizione: descrizione == null && nullToAbsent
          ? const Value.absent()
          : Value(descrizione),
      categoria: categoria == null && nullToAbsent
          ? const Value.absent()
          : Value(categoria),
      prezzoMinimoIndicativo: prezzoMinimoIndicativo == null && nullToAbsent
          ? const Value.absent()
          : Value(prezzoMinimoIndicativo),
      prezzoMassimoIndicativo: prezzoMassimoIndicativo == null && nullToAbsent
          ? const Value.absent()
          : Value(prezzoMassimoIndicativo),
      priorita: Value(priorita),
      queryRicerca: queryRicerca == null && nullToAbsent
          ? const Value.absent()
          : Value(queryRicerca),
      attiva: Value(attiva),
      versioneCatalogo: Value(versioneCatalogo),
      dataCreazione: Value(dataCreazione),
      dataModifica: Value(dataModifica),
    );
  }

  factory AttrezzatureTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AttrezzatureTableData(
      id: serializer.fromJson<int>(json['id']),
      codice: serializer.fromJson<String>(json['codice']),
      nome: serializer.fromJson<String>(json['nome']),
      descrizione: serializer.fromJson<String?>(json['descrizione']),
      categoria: serializer.fromJson<String?>(json['categoria']),
      prezzoMinimoIndicativo: serializer.fromJson<double?>(
        json['prezzoMinimoIndicativo'],
      ),
      prezzoMassimoIndicativo: serializer.fromJson<double?>(
        json['prezzoMassimoIndicativo'],
      ),
      priorita: serializer.fromJson<int>(json['priorita']),
      queryRicerca: serializer.fromJson<String?>(json['queryRicerca']),
      attiva: serializer.fromJson<bool>(json['attiva']),
      versioneCatalogo: serializer.fromJson<int>(json['versioneCatalogo']),
      dataCreazione: serializer.fromJson<DateTime>(json['dataCreazione']),
      dataModifica: serializer.fromJson<DateTime>(json['dataModifica']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'codice': serializer.toJson<String>(codice),
      'nome': serializer.toJson<String>(nome),
      'descrizione': serializer.toJson<String?>(descrizione),
      'categoria': serializer.toJson<String?>(categoria),
      'prezzoMinimoIndicativo': serializer.toJson<double?>(
        prezzoMinimoIndicativo,
      ),
      'prezzoMassimoIndicativo': serializer.toJson<double?>(
        prezzoMassimoIndicativo,
      ),
      'priorita': serializer.toJson<int>(priorita),
      'queryRicerca': serializer.toJson<String?>(queryRicerca),
      'attiva': serializer.toJson<bool>(attiva),
      'versioneCatalogo': serializer.toJson<int>(versioneCatalogo),
      'dataCreazione': serializer.toJson<DateTime>(dataCreazione),
      'dataModifica': serializer.toJson<DateTime>(dataModifica),
    };
  }

  AttrezzatureTableData copyWith({
    int? id,
    String? codice,
    String? nome,
    Value<String?> descrizione = const Value.absent(),
    Value<String?> categoria = const Value.absent(),
    Value<double?> prezzoMinimoIndicativo = const Value.absent(),
    Value<double?> prezzoMassimoIndicativo = const Value.absent(),
    int? priorita,
    Value<String?> queryRicerca = const Value.absent(),
    bool? attiva,
    int? versioneCatalogo,
    DateTime? dataCreazione,
    DateTime? dataModifica,
  }) => AttrezzatureTableData(
    id: id ?? this.id,
    codice: codice ?? this.codice,
    nome: nome ?? this.nome,
    descrizione: descrizione.present ? descrizione.value : this.descrizione,
    categoria: categoria.present ? categoria.value : this.categoria,
    prezzoMinimoIndicativo: prezzoMinimoIndicativo.present
        ? prezzoMinimoIndicativo.value
        : this.prezzoMinimoIndicativo,
    prezzoMassimoIndicativo: prezzoMassimoIndicativo.present
        ? prezzoMassimoIndicativo.value
        : this.prezzoMassimoIndicativo,
    priorita: priorita ?? this.priorita,
    queryRicerca: queryRicerca.present ? queryRicerca.value : this.queryRicerca,
    attiva: attiva ?? this.attiva,
    versioneCatalogo: versioneCatalogo ?? this.versioneCatalogo,
    dataCreazione: dataCreazione ?? this.dataCreazione,
    dataModifica: dataModifica ?? this.dataModifica,
  );
  AttrezzatureTableData copyWithCompanion(AttrezzatureTableCompanion data) {
    return AttrezzatureTableData(
      id: data.id.present ? data.id.value : this.id,
      codice: data.codice.present ? data.codice.value : this.codice,
      nome: data.nome.present ? data.nome.value : this.nome,
      descrizione: data.descrizione.present
          ? data.descrizione.value
          : this.descrizione,
      categoria: data.categoria.present ? data.categoria.value : this.categoria,
      prezzoMinimoIndicativo: data.prezzoMinimoIndicativo.present
          ? data.prezzoMinimoIndicativo.value
          : this.prezzoMinimoIndicativo,
      prezzoMassimoIndicativo: data.prezzoMassimoIndicativo.present
          ? data.prezzoMassimoIndicativo.value
          : this.prezzoMassimoIndicativo,
      priorita: data.priorita.present ? data.priorita.value : this.priorita,
      queryRicerca: data.queryRicerca.present
          ? data.queryRicerca.value
          : this.queryRicerca,
      attiva: data.attiva.present ? data.attiva.value : this.attiva,
      versioneCatalogo: data.versioneCatalogo.present
          ? data.versioneCatalogo.value
          : this.versioneCatalogo,
      dataCreazione: data.dataCreazione.present
          ? data.dataCreazione.value
          : this.dataCreazione,
      dataModifica: data.dataModifica.present
          ? data.dataModifica.value
          : this.dataModifica,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AttrezzatureTableData(')
          ..write('id: $id, ')
          ..write('codice: $codice, ')
          ..write('nome: $nome, ')
          ..write('descrizione: $descrizione, ')
          ..write('categoria: $categoria, ')
          ..write('prezzoMinimoIndicativo: $prezzoMinimoIndicativo, ')
          ..write('prezzoMassimoIndicativo: $prezzoMassimoIndicativo, ')
          ..write('priorita: $priorita, ')
          ..write('queryRicerca: $queryRicerca, ')
          ..write('attiva: $attiva, ')
          ..write('versioneCatalogo: $versioneCatalogo, ')
          ..write('dataCreazione: $dataCreazione, ')
          ..write('dataModifica: $dataModifica')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    codice,
    nome,
    descrizione,
    categoria,
    prezzoMinimoIndicativo,
    prezzoMassimoIndicativo,
    priorita,
    queryRicerca,
    attiva,
    versioneCatalogo,
    dataCreazione,
    dataModifica,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AttrezzatureTableData &&
          other.id == this.id &&
          other.codice == this.codice &&
          other.nome == this.nome &&
          other.descrizione == this.descrizione &&
          other.categoria == this.categoria &&
          other.prezzoMinimoIndicativo == this.prezzoMinimoIndicativo &&
          other.prezzoMassimoIndicativo == this.prezzoMassimoIndicativo &&
          other.priorita == this.priorita &&
          other.queryRicerca == this.queryRicerca &&
          other.attiva == this.attiva &&
          other.versioneCatalogo == this.versioneCatalogo &&
          other.dataCreazione == this.dataCreazione &&
          other.dataModifica == this.dataModifica);
}

class AttrezzatureTableCompanion
    extends UpdateCompanion<AttrezzatureTableData> {
  final Value<int> id;
  final Value<String> codice;
  final Value<String> nome;
  final Value<String?> descrizione;
  final Value<String?> categoria;
  final Value<double?> prezzoMinimoIndicativo;
  final Value<double?> prezzoMassimoIndicativo;
  final Value<int> priorita;
  final Value<String?> queryRicerca;
  final Value<bool> attiva;
  final Value<int> versioneCatalogo;
  final Value<DateTime> dataCreazione;
  final Value<DateTime> dataModifica;
  const AttrezzatureTableCompanion({
    this.id = const Value.absent(),
    this.codice = const Value.absent(),
    this.nome = const Value.absent(),
    this.descrizione = const Value.absent(),
    this.categoria = const Value.absent(),
    this.prezzoMinimoIndicativo = const Value.absent(),
    this.prezzoMassimoIndicativo = const Value.absent(),
    this.priorita = const Value.absent(),
    this.queryRicerca = const Value.absent(),
    this.attiva = const Value.absent(),
    this.versioneCatalogo = const Value.absent(),
    this.dataCreazione = const Value.absent(),
    this.dataModifica = const Value.absent(),
  });
  AttrezzatureTableCompanion.insert({
    this.id = const Value.absent(),
    required String codice,
    required String nome,
    this.descrizione = const Value.absent(),
    this.categoria = const Value.absent(),
    this.prezzoMinimoIndicativo = const Value.absent(),
    this.prezzoMassimoIndicativo = const Value.absent(),
    this.priorita = const Value.absent(),
    this.queryRicerca = const Value.absent(),
    this.attiva = const Value.absent(),
    required int versioneCatalogo,
    required DateTime dataCreazione,
    required DateTime dataModifica,
  }) : codice = Value(codice),
       nome = Value(nome),
       versioneCatalogo = Value(versioneCatalogo),
       dataCreazione = Value(dataCreazione),
       dataModifica = Value(dataModifica);
  static Insertable<AttrezzatureTableData> custom({
    Expression<int>? id,
    Expression<String>? codice,
    Expression<String>? nome,
    Expression<String>? descrizione,
    Expression<String>? categoria,
    Expression<double>? prezzoMinimoIndicativo,
    Expression<double>? prezzoMassimoIndicativo,
    Expression<int>? priorita,
    Expression<String>? queryRicerca,
    Expression<bool>? attiva,
    Expression<int>? versioneCatalogo,
    Expression<DateTime>? dataCreazione,
    Expression<DateTime>? dataModifica,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (codice != null) 'codice': codice,
      if (nome != null) 'nome': nome,
      if (descrizione != null) 'descrizione': descrizione,
      if (categoria != null) 'categoria': categoria,
      if (prezzoMinimoIndicativo != null)
        'prezzo_minimo_indicativo': prezzoMinimoIndicativo,
      if (prezzoMassimoIndicativo != null)
        'prezzo_massimo_indicativo': prezzoMassimoIndicativo,
      if (priorita != null) 'priorita': priorita,
      if (queryRicerca != null) 'query_ricerca': queryRicerca,
      if (attiva != null) 'attiva': attiva,
      if (versioneCatalogo != null) 'versione_catalogo': versioneCatalogo,
      if (dataCreazione != null) 'data_creazione': dataCreazione,
      if (dataModifica != null) 'data_modifica': dataModifica,
    });
  }

  AttrezzatureTableCompanion copyWith({
    Value<int>? id,
    Value<String>? codice,
    Value<String>? nome,
    Value<String?>? descrizione,
    Value<String?>? categoria,
    Value<double?>? prezzoMinimoIndicativo,
    Value<double?>? prezzoMassimoIndicativo,
    Value<int>? priorita,
    Value<String?>? queryRicerca,
    Value<bool>? attiva,
    Value<int>? versioneCatalogo,
    Value<DateTime>? dataCreazione,
    Value<DateTime>? dataModifica,
  }) {
    return AttrezzatureTableCompanion(
      id: id ?? this.id,
      codice: codice ?? this.codice,
      nome: nome ?? this.nome,
      descrizione: descrizione ?? this.descrizione,
      categoria: categoria ?? this.categoria,
      prezzoMinimoIndicativo:
          prezzoMinimoIndicativo ?? this.prezzoMinimoIndicativo,
      prezzoMassimoIndicativo:
          prezzoMassimoIndicativo ?? this.prezzoMassimoIndicativo,
      priorita: priorita ?? this.priorita,
      queryRicerca: queryRicerca ?? this.queryRicerca,
      attiva: attiva ?? this.attiva,
      versioneCatalogo: versioneCatalogo ?? this.versioneCatalogo,
      dataCreazione: dataCreazione ?? this.dataCreazione,
      dataModifica: dataModifica ?? this.dataModifica,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (codice.present) {
      map['codice'] = Variable<String>(codice.value);
    }
    if (nome.present) {
      map['nome'] = Variable<String>(nome.value);
    }
    if (descrizione.present) {
      map['descrizione'] = Variable<String>(descrizione.value);
    }
    if (categoria.present) {
      map['categoria'] = Variable<String>(categoria.value);
    }
    if (prezzoMinimoIndicativo.present) {
      map['prezzo_minimo_indicativo'] = Variable<double>(
        prezzoMinimoIndicativo.value,
      );
    }
    if (prezzoMassimoIndicativo.present) {
      map['prezzo_massimo_indicativo'] = Variable<double>(
        prezzoMassimoIndicativo.value,
      );
    }
    if (priorita.present) {
      map['priorita'] = Variable<int>(priorita.value);
    }
    if (queryRicerca.present) {
      map['query_ricerca'] = Variable<String>(queryRicerca.value);
    }
    if (attiva.present) {
      map['attiva'] = Variable<bool>(attiva.value);
    }
    if (versioneCatalogo.present) {
      map['versione_catalogo'] = Variable<int>(versioneCatalogo.value);
    }
    if (dataCreazione.present) {
      map['data_creazione'] = Variable<DateTime>(dataCreazione.value);
    }
    if (dataModifica.present) {
      map['data_modifica'] = Variable<DateTime>(dataModifica.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AttrezzatureTableCompanion(')
          ..write('id: $id, ')
          ..write('codice: $codice, ')
          ..write('nome: $nome, ')
          ..write('descrizione: $descrizione, ')
          ..write('categoria: $categoria, ')
          ..write('prezzoMinimoIndicativo: $prezzoMinimoIndicativo, ')
          ..write('prezzoMassimoIndicativo: $prezzoMassimoIndicativo, ')
          ..write('priorita: $priorita, ')
          ..write('queryRicerca: $queryRicerca, ')
          ..write('attiva: $attiva, ')
          ..write('versioneCatalogo: $versioneCatalogo, ')
          ..write('dataCreazione: $dataCreazione, ')
          ..write('dataModifica: $dataModifica')
          ..write(')'))
        .toString();
  }
}

class $AttrezzatureEserciziTableTable extends AttrezzatureEserciziTable
    with
        TableInfo<
          $AttrezzatureEserciziTableTable,
          AttrezzatureEserciziTableData
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AttrezzatureEserciziTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _idEsercizioMeta = const VerificationMeta(
    'idEsercizio',
  );
  @override
  late final GeneratedColumn<int> idEsercizio = GeneratedColumn<int>(
    'id_esercizio',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES esercizi (id)',
    ),
  );
  static const VerificationMeta _idAttrezzaturaMeta = const VerificationMeta(
    'idAttrezzatura',
  );
  @override
  late final GeneratedColumn<int> idAttrezzatura = GeneratedColumn<int>(
    'id_attrezzatura',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES attrezzature (id)',
    ),
  );
  static const VerificationMeta _obbligatoriaMeta = const VerificationMeta(
    'obbligatoria',
  );
  @override
  late final GeneratedColumn<bool> obbligatoria = GeneratedColumn<bool>(
    'obbligatoria',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("obbligatoria" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    idEsercizio,
    idAttrezzatura,
    obbligatoria,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attrezzature_esercizi';
  @override
  VerificationContext validateIntegrity(
    Insertable<AttrezzatureEserciziTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('id_esercizio')) {
      context.handle(
        _idEsercizioMeta,
        idEsercizio.isAcceptableOrUnknown(
          data['id_esercizio']!,
          _idEsercizioMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_idEsercizioMeta);
    }
    if (data.containsKey('id_attrezzatura')) {
      context.handle(
        _idAttrezzaturaMeta,
        idAttrezzatura.isAcceptableOrUnknown(
          data['id_attrezzatura']!,
          _idAttrezzaturaMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_idAttrezzaturaMeta);
    }
    if (data.containsKey('obbligatoria')) {
      context.handle(
        _obbligatoriaMeta,
        obbligatoria.isAcceptableOrUnknown(
          data['obbligatoria']!,
          _obbligatoriaMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {idEsercizio, idAttrezzatura},
  ];
  @override
  AttrezzatureEserciziTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AttrezzatureEserciziTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      idEsercizio: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id_esercizio'],
      )!,
      idAttrezzatura: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id_attrezzatura'],
      )!,
      obbligatoria: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}obbligatoria'],
      )!,
    );
  }

  @override
  $AttrezzatureEserciziTableTable createAlias(String alias) {
    return $AttrezzatureEserciziTableTable(attachedDatabase, alias);
  }
}

class AttrezzatureEserciziTableData extends DataClass
    implements Insertable<AttrezzatureEserciziTableData> {
  final int id;
  final int idEsercizio;
  final int idAttrezzatura;
  final bool obbligatoria;
  const AttrezzatureEserciziTableData({
    required this.id,
    required this.idEsercizio,
    required this.idAttrezzatura,
    required this.obbligatoria,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['id_esercizio'] = Variable<int>(idEsercizio);
    map['id_attrezzatura'] = Variable<int>(idAttrezzatura);
    map['obbligatoria'] = Variable<bool>(obbligatoria);
    return map;
  }

  AttrezzatureEserciziTableCompanion toCompanion(bool nullToAbsent) {
    return AttrezzatureEserciziTableCompanion(
      id: Value(id),
      idEsercizio: Value(idEsercizio),
      idAttrezzatura: Value(idAttrezzatura),
      obbligatoria: Value(obbligatoria),
    );
  }

  factory AttrezzatureEserciziTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AttrezzatureEserciziTableData(
      id: serializer.fromJson<int>(json['id']),
      idEsercizio: serializer.fromJson<int>(json['idEsercizio']),
      idAttrezzatura: serializer.fromJson<int>(json['idAttrezzatura']),
      obbligatoria: serializer.fromJson<bool>(json['obbligatoria']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'idEsercizio': serializer.toJson<int>(idEsercizio),
      'idAttrezzatura': serializer.toJson<int>(idAttrezzatura),
      'obbligatoria': serializer.toJson<bool>(obbligatoria),
    };
  }

  AttrezzatureEserciziTableData copyWith({
    int? id,
    int? idEsercizio,
    int? idAttrezzatura,
    bool? obbligatoria,
  }) => AttrezzatureEserciziTableData(
    id: id ?? this.id,
    idEsercizio: idEsercizio ?? this.idEsercizio,
    idAttrezzatura: idAttrezzatura ?? this.idAttrezzatura,
    obbligatoria: obbligatoria ?? this.obbligatoria,
  );
  AttrezzatureEserciziTableData copyWithCompanion(
    AttrezzatureEserciziTableCompanion data,
  ) {
    return AttrezzatureEserciziTableData(
      id: data.id.present ? data.id.value : this.id,
      idEsercizio: data.idEsercizio.present
          ? data.idEsercizio.value
          : this.idEsercizio,
      idAttrezzatura: data.idAttrezzatura.present
          ? data.idAttrezzatura.value
          : this.idAttrezzatura,
      obbligatoria: data.obbligatoria.present
          ? data.obbligatoria.value
          : this.obbligatoria,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AttrezzatureEserciziTableData(')
          ..write('id: $id, ')
          ..write('idEsercizio: $idEsercizio, ')
          ..write('idAttrezzatura: $idAttrezzatura, ')
          ..write('obbligatoria: $obbligatoria')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, idEsercizio, idAttrezzatura, obbligatoria);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AttrezzatureEserciziTableData &&
          other.id == this.id &&
          other.idEsercizio == this.idEsercizio &&
          other.idAttrezzatura == this.idAttrezzatura &&
          other.obbligatoria == this.obbligatoria);
}

class AttrezzatureEserciziTableCompanion
    extends UpdateCompanion<AttrezzatureEserciziTableData> {
  final Value<int> id;
  final Value<int> idEsercizio;
  final Value<int> idAttrezzatura;
  final Value<bool> obbligatoria;
  const AttrezzatureEserciziTableCompanion({
    this.id = const Value.absent(),
    this.idEsercizio = const Value.absent(),
    this.idAttrezzatura = const Value.absent(),
    this.obbligatoria = const Value.absent(),
  });
  AttrezzatureEserciziTableCompanion.insert({
    this.id = const Value.absent(),
    required int idEsercizio,
    required int idAttrezzatura,
    this.obbligatoria = const Value.absent(),
  }) : idEsercizio = Value(idEsercizio),
       idAttrezzatura = Value(idAttrezzatura);
  static Insertable<AttrezzatureEserciziTableData> custom({
    Expression<int>? id,
    Expression<int>? idEsercizio,
    Expression<int>? idAttrezzatura,
    Expression<bool>? obbligatoria,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (idEsercizio != null) 'id_esercizio': idEsercizio,
      if (idAttrezzatura != null) 'id_attrezzatura': idAttrezzatura,
      if (obbligatoria != null) 'obbligatoria': obbligatoria,
    });
  }

  AttrezzatureEserciziTableCompanion copyWith({
    Value<int>? id,
    Value<int>? idEsercizio,
    Value<int>? idAttrezzatura,
    Value<bool>? obbligatoria,
  }) {
    return AttrezzatureEserciziTableCompanion(
      id: id ?? this.id,
      idEsercizio: idEsercizio ?? this.idEsercizio,
      idAttrezzatura: idAttrezzatura ?? this.idAttrezzatura,
      obbligatoria: obbligatoria ?? this.obbligatoria,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (idEsercizio.present) {
      map['id_esercizio'] = Variable<int>(idEsercizio.value);
    }
    if (idAttrezzatura.present) {
      map['id_attrezzatura'] = Variable<int>(idAttrezzatura.value);
    }
    if (obbligatoria.present) {
      map['obbligatoria'] = Variable<bool>(obbligatoria.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AttrezzatureEserciziTableCompanion(')
          ..write('id: $id, ')
          ..write('idEsercizio: $idEsercizio, ')
          ..write('idAttrezzatura: $idAttrezzatura, ')
          ..write('obbligatoria: $obbligatoria')
          ..write(')'))
        .toString();
  }
}

class $ImmaginiEserciziTableTable extends ImmaginiEserciziTable
    with TableInfo<$ImmaginiEserciziTableTable, ImmaginiEserciziTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ImmaginiEserciziTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _idEsercizioMeta = const VerificationMeta(
    'idEsercizio',
  );
  @override
  late final GeneratedColumn<int> idEsercizio = GeneratedColumn<int>(
    'id_esercizio',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES esercizi (id)',
    ),
  );
  static const VerificationMeta _tipoSorgenteMeta = const VerificationMeta(
    'tipoSorgente',
  );
  @override
  late final GeneratedColumn<String> tipoSorgente = GeneratedColumn<String>(
    'tipo_sorgente',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _percorsoAssetMeta = const VerificationMeta(
    'percorsoAsset',
  );
  @override
  late final GeneratedColumn<String> percorsoAsset = GeneratedColumn<String>(
    'percorso_asset',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _percorsoFileLocaleMeta =
      const VerificationMeta('percorsoFileLocale');
  @override
  late final GeneratedColumn<String> percorsoFileLocale =
      GeneratedColumn<String>(
        'percorso_file_locale',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _tipoImmagineMeta = const VerificationMeta(
    'tipoImmagine',
  );
  @override
  late final GeneratedColumn<String> tipoImmagine = GeneratedColumn<String>(
    'tipo_immagine',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _didascaliaMeta = const VerificationMeta(
    'didascalia',
  );
  @override
  late final GeneratedColumn<String> didascalia = GeneratedColumn<String>(
    'didascalia',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ordineVisualizzazioneMeta =
      const VerificationMeta('ordineVisualizzazione');
  @override
  late final GeneratedColumn<int> ordineVisualizzazione = GeneratedColumn<int>(
    'ordine_visualizzazione',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _attivaMeta = const VerificationMeta('attiva');
  @override
  late final GeneratedColumn<bool> attiva = GeneratedColumn<bool>(
    'attiva',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("attiva" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _dataCreazioneMeta = const VerificationMeta(
    'dataCreazione',
  );
  @override
  late final GeneratedColumn<DateTime> dataCreazione =
      GeneratedColumn<DateTime>(
        'data_creazione',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _dataModificaMeta = const VerificationMeta(
    'dataModifica',
  );
  @override
  late final GeneratedColumn<DateTime> dataModifica = GeneratedColumn<DateTime>(
    'data_modifica',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    idEsercizio,
    tipoSorgente,
    percorsoAsset,
    percorsoFileLocale,
    tipoImmagine,
    didascalia,
    ordineVisualizzazione,
    attiva,
    dataCreazione,
    dataModifica,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'immagini_esercizi';
  @override
  VerificationContext validateIntegrity(
    Insertable<ImmaginiEserciziTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('id_esercizio')) {
      context.handle(
        _idEsercizioMeta,
        idEsercizio.isAcceptableOrUnknown(
          data['id_esercizio']!,
          _idEsercizioMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_idEsercizioMeta);
    }
    if (data.containsKey('tipo_sorgente')) {
      context.handle(
        _tipoSorgenteMeta,
        tipoSorgente.isAcceptableOrUnknown(
          data['tipo_sorgente']!,
          _tipoSorgenteMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_tipoSorgenteMeta);
    }
    if (data.containsKey('percorso_asset')) {
      context.handle(
        _percorsoAssetMeta,
        percorsoAsset.isAcceptableOrUnknown(
          data['percorso_asset']!,
          _percorsoAssetMeta,
        ),
      );
    }
    if (data.containsKey('percorso_file_locale')) {
      context.handle(
        _percorsoFileLocaleMeta,
        percorsoFileLocale.isAcceptableOrUnknown(
          data['percorso_file_locale']!,
          _percorsoFileLocaleMeta,
        ),
      );
    }
    if (data.containsKey('tipo_immagine')) {
      context.handle(
        _tipoImmagineMeta,
        tipoImmagine.isAcceptableOrUnknown(
          data['tipo_immagine']!,
          _tipoImmagineMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_tipoImmagineMeta);
    }
    if (data.containsKey('didascalia')) {
      context.handle(
        _didascaliaMeta,
        didascalia.isAcceptableOrUnknown(data['didascalia']!, _didascaliaMeta),
      );
    }
    if (data.containsKey('ordine_visualizzazione')) {
      context.handle(
        _ordineVisualizzazioneMeta,
        ordineVisualizzazione.isAcceptableOrUnknown(
          data['ordine_visualizzazione']!,
          _ordineVisualizzazioneMeta,
        ),
      );
    }
    if (data.containsKey('attiva')) {
      context.handle(
        _attivaMeta,
        attiva.isAcceptableOrUnknown(data['attiva']!, _attivaMeta),
      );
    }
    if (data.containsKey('data_creazione')) {
      context.handle(
        _dataCreazioneMeta,
        dataCreazione.isAcceptableOrUnknown(
          data['data_creazione']!,
          _dataCreazioneMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dataCreazioneMeta);
    }
    if (data.containsKey('data_modifica')) {
      context.handle(
        _dataModificaMeta,
        dataModifica.isAcceptableOrUnknown(
          data['data_modifica']!,
          _dataModificaMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dataModificaMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ImmaginiEserciziTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ImmaginiEserciziTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      idEsercizio: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id_esercizio'],
      )!,
      tipoSorgente: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tipo_sorgente'],
      )!,
      percorsoAsset: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}percorso_asset'],
      ),
      percorsoFileLocale: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}percorso_file_locale'],
      ),
      tipoImmagine: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tipo_immagine'],
      )!,
      didascalia: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}didascalia'],
      ),
      ordineVisualizzazione: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ordine_visualizzazione'],
      )!,
      attiva: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}attiva'],
      )!,
      dataCreazione: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}data_creazione'],
      )!,
      dataModifica: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}data_modifica'],
      )!,
    );
  }

  @override
  $ImmaginiEserciziTableTable createAlias(String alias) {
    return $ImmaginiEserciziTableTable(attachedDatabase, alias);
  }
}

class ImmaginiEserciziTableData extends DataClass
    implements Insertable<ImmaginiEserciziTableData> {
  final int id;
  final int idEsercizio;

  /// Codice stabile di [ExerciseImageSourceType].
  final String tipoSorgente;
  final String? percorsoAsset;
  final String? percorsoFileLocale;

  /// Codice stabile di [ExerciseImageType].
  final String tipoImmagine;
  final String? didascalia;
  final int ordineVisualizzazione;
  final bool attiva;
  final DateTime dataCreazione;
  final DateTime dataModifica;
  const ImmaginiEserciziTableData({
    required this.id,
    required this.idEsercizio,
    required this.tipoSorgente,
    this.percorsoAsset,
    this.percorsoFileLocale,
    required this.tipoImmagine,
    this.didascalia,
    required this.ordineVisualizzazione,
    required this.attiva,
    required this.dataCreazione,
    required this.dataModifica,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['id_esercizio'] = Variable<int>(idEsercizio);
    map['tipo_sorgente'] = Variable<String>(tipoSorgente);
    if (!nullToAbsent || percorsoAsset != null) {
      map['percorso_asset'] = Variable<String>(percorsoAsset);
    }
    if (!nullToAbsent || percorsoFileLocale != null) {
      map['percorso_file_locale'] = Variable<String>(percorsoFileLocale);
    }
    map['tipo_immagine'] = Variable<String>(tipoImmagine);
    if (!nullToAbsent || didascalia != null) {
      map['didascalia'] = Variable<String>(didascalia);
    }
    map['ordine_visualizzazione'] = Variable<int>(ordineVisualizzazione);
    map['attiva'] = Variable<bool>(attiva);
    map['data_creazione'] = Variable<DateTime>(dataCreazione);
    map['data_modifica'] = Variable<DateTime>(dataModifica);
    return map;
  }

  ImmaginiEserciziTableCompanion toCompanion(bool nullToAbsent) {
    return ImmaginiEserciziTableCompanion(
      id: Value(id),
      idEsercizio: Value(idEsercizio),
      tipoSorgente: Value(tipoSorgente),
      percorsoAsset: percorsoAsset == null && nullToAbsent
          ? const Value.absent()
          : Value(percorsoAsset),
      percorsoFileLocale: percorsoFileLocale == null && nullToAbsent
          ? const Value.absent()
          : Value(percorsoFileLocale),
      tipoImmagine: Value(tipoImmagine),
      didascalia: didascalia == null && nullToAbsent
          ? const Value.absent()
          : Value(didascalia),
      ordineVisualizzazione: Value(ordineVisualizzazione),
      attiva: Value(attiva),
      dataCreazione: Value(dataCreazione),
      dataModifica: Value(dataModifica),
    );
  }

  factory ImmaginiEserciziTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ImmaginiEserciziTableData(
      id: serializer.fromJson<int>(json['id']),
      idEsercizio: serializer.fromJson<int>(json['idEsercizio']),
      tipoSorgente: serializer.fromJson<String>(json['tipoSorgente']),
      percorsoAsset: serializer.fromJson<String?>(json['percorsoAsset']),
      percorsoFileLocale: serializer.fromJson<String?>(
        json['percorsoFileLocale'],
      ),
      tipoImmagine: serializer.fromJson<String>(json['tipoImmagine']),
      didascalia: serializer.fromJson<String?>(json['didascalia']),
      ordineVisualizzazione: serializer.fromJson<int>(
        json['ordineVisualizzazione'],
      ),
      attiva: serializer.fromJson<bool>(json['attiva']),
      dataCreazione: serializer.fromJson<DateTime>(json['dataCreazione']),
      dataModifica: serializer.fromJson<DateTime>(json['dataModifica']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'idEsercizio': serializer.toJson<int>(idEsercizio),
      'tipoSorgente': serializer.toJson<String>(tipoSorgente),
      'percorsoAsset': serializer.toJson<String?>(percorsoAsset),
      'percorsoFileLocale': serializer.toJson<String?>(percorsoFileLocale),
      'tipoImmagine': serializer.toJson<String>(tipoImmagine),
      'didascalia': serializer.toJson<String?>(didascalia),
      'ordineVisualizzazione': serializer.toJson<int>(ordineVisualizzazione),
      'attiva': serializer.toJson<bool>(attiva),
      'dataCreazione': serializer.toJson<DateTime>(dataCreazione),
      'dataModifica': serializer.toJson<DateTime>(dataModifica),
    };
  }

  ImmaginiEserciziTableData copyWith({
    int? id,
    int? idEsercizio,
    String? tipoSorgente,
    Value<String?> percorsoAsset = const Value.absent(),
    Value<String?> percorsoFileLocale = const Value.absent(),
    String? tipoImmagine,
    Value<String?> didascalia = const Value.absent(),
    int? ordineVisualizzazione,
    bool? attiva,
    DateTime? dataCreazione,
    DateTime? dataModifica,
  }) => ImmaginiEserciziTableData(
    id: id ?? this.id,
    idEsercizio: idEsercizio ?? this.idEsercizio,
    tipoSorgente: tipoSorgente ?? this.tipoSorgente,
    percorsoAsset: percorsoAsset.present
        ? percorsoAsset.value
        : this.percorsoAsset,
    percorsoFileLocale: percorsoFileLocale.present
        ? percorsoFileLocale.value
        : this.percorsoFileLocale,
    tipoImmagine: tipoImmagine ?? this.tipoImmagine,
    didascalia: didascalia.present ? didascalia.value : this.didascalia,
    ordineVisualizzazione: ordineVisualizzazione ?? this.ordineVisualizzazione,
    attiva: attiva ?? this.attiva,
    dataCreazione: dataCreazione ?? this.dataCreazione,
    dataModifica: dataModifica ?? this.dataModifica,
  );
  ImmaginiEserciziTableData copyWithCompanion(
    ImmaginiEserciziTableCompanion data,
  ) {
    return ImmaginiEserciziTableData(
      id: data.id.present ? data.id.value : this.id,
      idEsercizio: data.idEsercizio.present
          ? data.idEsercizio.value
          : this.idEsercizio,
      tipoSorgente: data.tipoSorgente.present
          ? data.tipoSorgente.value
          : this.tipoSorgente,
      percorsoAsset: data.percorsoAsset.present
          ? data.percorsoAsset.value
          : this.percorsoAsset,
      percorsoFileLocale: data.percorsoFileLocale.present
          ? data.percorsoFileLocale.value
          : this.percorsoFileLocale,
      tipoImmagine: data.tipoImmagine.present
          ? data.tipoImmagine.value
          : this.tipoImmagine,
      didascalia: data.didascalia.present
          ? data.didascalia.value
          : this.didascalia,
      ordineVisualizzazione: data.ordineVisualizzazione.present
          ? data.ordineVisualizzazione.value
          : this.ordineVisualizzazione,
      attiva: data.attiva.present ? data.attiva.value : this.attiva,
      dataCreazione: data.dataCreazione.present
          ? data.dataCreazione.value
          : this.dataCreazione,
      dataModifica: data.dataModifica.present
          ? data.dataModifica.value
          : this.dataModifica,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ImmaginiEserciziTableData(')
          ..write('id: $id, ')
          ..write('idEsercizio: $idEsercizio, ')
          ..write('tipoSorgente: $tipoSorgente, ')
          ..write('percorsoAsset: $percorsoAsset, ')
          ..write('percorsoFileLocale: $percorsoFileLocale, ')
          ..write('tipoImmagine: $tipoImmagine, ')
          ..write('didascalia: $didascalia, ')
          ..write('ordineVisualizzazione: $ordineVisualizzazione, ')
          ..write('attiva: $attiva, ')
          ..write('dataCreazione: $dataCreazione, ')
          ..write('dataModifica: $dataModifica')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    idEsercizio,
    tipoSorgente,
    percorsoAsset,
    percorsoFileLocale,
    tipoImmagine,
    didascalia,
    ordineVisualizzazione,
    attiva,
    dataCreazione,
    dataModifica,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ImmaginiEserciziTableData &&
          other.id == this.id &&
          other.idEsercizio == this.idEsercizio &&
          other.tipoSorgente == this.tipoSorgente &&
          other.percorsoAsset == this.percorsoAsset &&
          other.percorsoFileLocale == this.percorsoFileLocale &&
          other.tipoImmagine == this.tipoImmagine &&
          other.didascalia == this.didascalia &&
          other.ordineVisualizzazione == this.ordineVisualizzazione &&
          other.attiva == this.attiva &&
          other.dataCreazione == this.dataCreazione &&
          other.dataModifica == this.dataModifica);
}

class ImmaginiEserciziTableCompanion
    extends UpdateCompanion<ImmaginiEserciziTableData> {
  final Value<int> id;
  final Value<int> idEsercizio;
  final Value<String> tipoSorgente;
  final Value<String?> percorsoAsset;
  final Value<String?> percorsoFileLocale;
  final Value<String> tipoImmagine;
  final Value<String?> didascalia;
  final Value<int> ordineVisualizzazione;
  final Value<bool> attiva;
  final Value<DateTime> dataCreazione;
  final Value<DateTime> dataModifica;
  const ImmaginiEserciziTableCompanion({
    this.id = const Value.absent(),
    this.idEsercizio = const Value.absent(),
    this.tipoSorgente = const Value.absent(),
    this.percorsoAsset = const Value.absent(),
    this.percorsoFileLocale = const Value.absent(),
    this.tipoImmagine = const Value.absent(),
    this.didascalia = const Value.absent(),
    this.ordineVisualizzazione = const Value.absent(),
    this.attiva = const Value.absent(),
    this.dataCreazione = const Value.absent(),
    this.dataModifica = const Value.absent(),
  });
  ImmaginiEserciziTableCompanion.insert({
    this.id = const Value.absent(),
    required int idEsercizio,
    required String tipoSorgente,
    this.percorsoAsset = const Value.absent(),
    this.percorsoFileLocale = const Value.absent(),
    required String tipoImmagine,
    this.didascalia = const Value.absent(),
    this.ordineVisualizzazione = const Value.absent(),
    this.attiva = const Value.absent(),
    required DateTime dataCreazione,
    required DateTime dataModifica,
  }) : idEsercizio = Value(idEsercizio),
       tipoSorgente = Value(tipoSorgente),
       tipoImmagine = Value(tipoImmagine),
       dataCreazione = Value(dataCreazione),
       dataModifica = Value(dataModifica);
  static Insertable<ImmaginiEserciziTableData> custom({
    Expression<int>? id,
    Expression<int>? idEsercizio,
    Expression<String>? tipoSorgente,
    Expression<String>? percorsoAsset,
    Expression<String>? percorsoFileLocale,
    Expression<String>? tipoImmagine,
    Expression<String>? didascalia,
    Expression<int>? ordineVisualizzazione,
    Expression<bool>? attiva,
    Expression<DateTime>? dataCreazione,
    Expression<DateTime>? dataModifica,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (idEsercizio != null) 'id_esercizio': idEsercizio,
      if (tipoSorgente != null) 'tipo_sorgente': tipoSorgente,
      if (percorsoAsset != null) 'percorso_asset': percorsoAsset,
      if (percorsoFileLocale != null)
        'percorso_file_locale': percorsoFileLocale,
      if (tipoImmagine != null) 'tipo_immagine': tipoImmagine,
      if (didascalia != null) 'didascalia': didascalia,
      if (ordineVisualizzazione != null)
        'ordine_visualizzazione': ordineVisualizzazione,
      if (attiva != null) 'attiva': attiva,
      if (dataCreazione != null) 'data_creazione': dataCreazione,
      if (dataModifica != null) 'data_modifica': dataModifica,
    });
  }

  ImmaginiEserciziTableCompanion copyWith({
    Value<int>? id,
    Value<int>? idEsercizio,
    Value<String>? tipoSorgente,
    Value<String?>? percorsoAsset,
    Value<String?>? percorsoFileLocale,
    Value<String>? tipoImmagine,
    Value<String?>? didascalia,
    Value<int>? ordineVisualizzazione,
    Value<bool>? attiva,
    Value<DateTime>? dataCreazione,
    Value<DateTime>? dataModifica,
  }) {
    return ImmaginiEserciziTableCompanion(
      id: id ?? this.id,
      idEsercizio: idEsercizio ?? this.idEsercizio,
      tipoSorgente: tipoSorgente ?? this.tipoSorgente,
      percorsoAsset: percorsoAsset ?? this.percorsoAsset,
      percorsoFileLocale: percorsoFileLocale ?? this.percorsoFileLocale,
      tipoImmagine: tipoImmagine ?? this.tipoImmagine,
      didascalia: didascalia ?? this.didascalia,
      ordineVisualizzazione:
          ordineVisualizzazione ?? this.ordineVisualizzazione,
      attiva: attiva ?? this.attiva,
      dataCreazione: dataCreazione ?? this.dataCreazione,
      dataModifica: dataModifica ?? this.dataModifica,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (idEsercizio.present) {
      map['id_esercizio'] = Variable<int>(idEsercizio.value);
    }
    if (tipoSorgente.present) {
      map['tipo_sorgente'] = Variable<String>(tipoSorgente.value);
    }
    if (percorsoAsset.present) {
      map['percorso_asset'] = Variable<String>(percorsoAsset.value);
    }
    if (percorsoFileLocale.present) {
      map['percorso_file_locale'] = Variable<String>(percorsoFileLocale.value);
    }
    if (tipoImmagine.present) {
      map['tipo_immagine'] = Variable<String>(tipoImmagine.value);
    }
    if (didascalia.present) {
      map['didascalia'] = Variable<String>(didascalia.value);
    }
    if (ordineVisualizzazione.present) {
      map['ordine_visualizzazione'] = Variable<int>(
        ordineVisualizzazione.value,
      );
    }
    if (attiva.present) {
      map['attiva'] = Variable<bool>(attiva.value);
    }
    if (dataCreazione.present) {
      map['data_creazione'] = Variable<DateTime>(dataCreazione.value);
    }
    if (dataModifica.present) {
      map['data_modifica'] = Variable<DateTime>(dataModifica.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ImmaginiEserciziTableCompanion(')
          ..write('id: $id, ')
          ..write('idEsercizio: $idEsercizio, ')
          ..write('tipoSorgente: $tipoSorgente, ')
          ..write('percorsoAsset: $percorsoAsset, ')
          ..write('percorsoFileLocale: $percorsoFileLocale, ')
          ..write('tipoImmagine: $tipoImmagine, ')
          ..write('didascalia: $didascalia, ')
          ..write('ordineVisualizzazione: $ordineVisualizzazione, ')
          ..write('attiva: $attiva, ')
          ..write('dataCreazione: $dataCreazione, ')
          ..write('dataModifica: $dataModifica')
          ..write(')'))
        .toString();
  }
}

class $ProgressioniEserciziTableTable extends ProgressioniEserciziTable
    with
        TableInfo<
          $ProgressioniEserciziTableTable,
          ProgressioniEserciziTableData
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProgressioniEserciziTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _idEsercizioMeta = const VerificationMeta(
    'idEsercizio',
  );
  @override
  late final GeneratedColumn<int> idEsercizio = GeneratedColumn<int>(
    'id_esercizio',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES esercizi (id)',
    ),
  );
  static const VerificationMeta _idEsercizioSuccessivoMeta =
      const VerificationMeta('idEsercizioSuccessivo');
  @override
  late final GeneratedColumn<int> idEsercizioSuccessivo = GeneratedColumn<int>(
    'id_esercizio_successivo',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES esercizi (id)',
    ),
  );
  static const VerificationMeta _tipoProgressioneMeta = const VerificationMeta(
    'tipoProgressione',
  );
  @override
  late final GeneratedColumn<String> tipoProgressione = GeneratedColumn<String>(
    'tipo_progressione',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _livelloMinimoMeta = const VerificationMeta(
    'livelloMinimo',
  );
  @override
  late final GeneratedColumn<int> livelloMinimo = GeneratedColumn<int>(
    'livello_minimo',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _prioritaMeta = const VerificationMeta(
    'priorita',
  );
  @override
  late final GeneratedColumn<int> priorita = GeneratedColumn<int>(
    'priorita',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _attivaMeta = const VerificationMeta('attiva');
  @override
  late final GeneratedColumn<bool> attiva = GeneratedColumn<bool>(
    'attiva',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("attiva" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _dataCreazioneMeta = const VerificationMeta(
    'dataCreazione',
  );
  @override
  late final GeneratedColumn<DateTime> dataCreazione =
      GeneratedColumn<DateTime>(
        'data_creazione',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _dataModificaMeta = const VerificationMeta(
    'dataModifica',
  );
  @override
  late final GeneratedColumn<DateTime> dataModifica = GeneratedColumn<DateTime>(
    'data_modifica',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    idEsercizio,
    idEsercizioSuccessivo,
    tipoProgressione,
    livelloMinimo,
    priorita,
    note,
    attiva,
    dataCreazione,
    dataModifica,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'progressioni_esercizi';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProgressioniEserciziTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('id_esercizio')) {
      context.handle(
        _idEsercizioMeta,
        idEsercizio.isAcceptableOrUnknown(
          data['id_esercizio']!,
          _idEsercizioMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_idEsercizioMeta);
    }
    if (data.containsKey('id_esercizio_successivo')) {
      context.handle(
        _idEsercizioSuccessivoMeta,
        idEsercizioSuccessivo.isAcceptableOrUnknown(
          data['id_esercizio_successivo']!,
          _idEsercizioSuccessivoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_idEsercizioSuccessivoMeta);
    }
    if (data.containsKey('tipo_progressione')) {
      context.handle(
        _tipoProgressioneMeta,
        tipoProgressione.isAcceptableOrUnknown(
          data['tipo_progressione']!,
          _tipoProgressioneMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_tipoProgressioneMeta);
    }
    if (data.containsKey('livello_minimo')) {
      context.handle(
        _livelloMinimoMeta,
        livelloMinimo.isAcceptableOrUnknown(
          data['livello_minimo']!,
          _livelloMinimoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_livelloMinimoMeta);
    }
    if (data.containsKey('priorita')) {
      context.handle(
        _prioritaMeta,
        priorita.isAcceptableOrUnknown(data['priorita']!, _prioritaMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('attiva')) {
      context.handle(
        _attivaMeta,
        attiva.isAcceptableOrUnknown(data['attiva']!, _attivaMeta),
      );
    }
    if (data.containsKey('data_creazione')) {
      context.handle(
        _dataCreazioneMeta,
        dataCreazione.isAcceptableOrUnknown(
          data['data_creazione']!,
          _dataCreazioneMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dataCreazioneMeta);
    }
    if (data.containsKey('data_modifica')) {
      context.handle(
        _dataModificaMeta,
        dataModifica.isAcceptableOrUnknown(
          data['data_modifica']!,
          _dataModificaMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dataModificaMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {idEsercizio, idEsercizioSuccessivo},
  ];
  @override
  ProgressioniEserciziTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProgressioniEserciziTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      idEsercizio: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id_esercizio'],
      )!,
      idEsercizioSuccessivo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id_esercizio_successivo'],
      )!,
      tipoProgressione: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tipo_progressione'],
      )!,
      livelloMinimo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}livello_minimo'],
      )!,
      priorita: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}priorita'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      attiva: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}attiva'],
      )!,
      dataCreazione: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}data_creazione'],
      )!,
      dataModifica: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}data_modifica'],
      )!,
    );
  }

  @override
  $ProgressioniEserciziTableTable createAlias(String alias) {
    return $ProgressioniEserciziTableTable(attachedDatabase, alias);
  }
}

class ProgressioniEserciziTableData extends DataClass
    implements Insertable<ProgressioniEserciziTableData> {
  final int id;
  final int idEsercizio;
  final int idEsercizioSuccessivo;

  /// Codice stabile di [ExerciseProgressionType].
  final String tipoProgressione;
  final int livelloMinimo;
  final int priorita;
  final String? note;
  final bool attiva;
  final DateTime dataCreazione;
  final DateTime dataModifica;
  const ProgressioniEserciziTableData({
    required this.id,
    required this.idEsercizio,
    required this.idEsercizioSuccessivo,
    required this.tipoProgressione,
    required this.livelloMinimo,
    required this.priorita,
    this.note,
    required this.attiva,
    required this.dataCreazione,
    required this.dataModifica,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['id_esercizio'] = Variable<int>(idEsercizio);
    map['id_esercizio_successivo'] = Variable<int>(idEsercizioSuccessivo);
    map['tipo_progressione'] = Variable<String>(tipoProgressione);
    map['livello_minimo'] = Variable<int>(livelloMinimo);
    map['priorita'] = Variable<int>(priorita);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['attiva'] = Variable<bool>(attiva);
    map['data_creazione'] = Variable<DateTime>(dataCreazione);
    map['data_modifica'] = Variable<DateTime>(dataModifica);
    return map;
  }

  ProgressioniEserciziTableCompanion toCompanion(bool nullToAbsent) {
    return ProgressioniEserciziTableCompanion(
      id: Value(id),
      idEsercizio: Value(idEsercizio),
      idEsercizioSuccessivo: Value(idEsercizioSuccessivo),
      tipoProgressione: Value(tipoProgressione),
      livelloMinimo: Value(livelloMinimo),
      priorita: Value(priorita),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      attiva: Value(attiva),
      dataCreazione: Value(dataCreazione),
      dataModifica: Value(dataModifica),
    );
  }

  factory ProgressioniEserciziTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProgressioniEserciziTableData(
      id: serializer.fromJson<int>(json['id']),
      idEsercizio: serializer.fromJson<int>(json['idEsercizio']),
      idEsercizioSuccessivo: serializer.fromJson<int>(
        json['idEsercizioSuccessivo'],
      ),
      tipoProgressione: serializer.fromJson<String>(json['tipoProgressione']),
      livelloMinimo: serializer.fromJson<int>(json['livelloMinimo']),
      priorita: serializer.fromJson<int>(json['priorita']),
      note: serializer.fromJson<String?>(json['note']),
      attiva: serializer.fromJson<bool>(json['attiva']),
      dataCreazione: serializer.fromJson<DateTime>(json['dataCreazione']),
      dataModifica: serializer.fromJson<DateTime>(json['dataModifica']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'idEsercizio': serializer.toJson<int>(idEsercizio),
      'idEsercizioSuccessivo': serializer.toJson<int>(idEsercizioSuccessivo),
      'tipoProgressione': serializer.toJson<String>(tipoProgressione),
      'livelloMinimo': serializer.toJson<int>(livelloMinimo),
      'priorita': serializer.toJson<int>(priorita),
      'note': serializer.toJson<String?>(note),
      'attiva': serializer.toJson<bool>(attiva),
      'dataCreazione': serializer.toJson<DateTime>(dataCreazione),
      'dataModifica': serializer.toJson<DateTime>(dataModifica),
    };
  }

  ProgressioniEserciziTableData copyWith({
    int? id,
    int? idEsercizio,
    int? idEsercizioSuccessivo,
    String? tipoProgressione,
    int? livelloMinimo,
    int? priorita,
    Value<String?> note = const Value.absent(),
    bool? attiva,
    DateTime? dataCreazione,
    DateTime? dataModifica,
  }) => ProgressioniEserciziTableData(
    id: id ?? this.id,
    idEsercizio: idEsercizio ?? this.idEsercizio,
    idEsercizioSuccessivo: idEsercizioSuccessivo ?? this.idEsercizioSuccessivo,
    tipoProgressione: tipoProgressione ?? this.tipoProgressione,
    livelloMinimo: livelloMinimo ?? this.livelloMinimo,
    priorita: priorita ?? this.priorita,
    note: note.present ? note.value : this.note,
    attiva: attiva ?? this.attiva,
    dataCreazione: dataCreazione ?? this.dataCreazione,
    dataModifica: dataModifica ?? this.dataModifica,
  );
  ProgressioniEserciziTableData copyWithCompanion(
    ProgressioniEserciziTableCompanion data,
  ) {
    return ProgressioniEserciziTableData(
      id: data.id.present ? data.id.value : this.id,
      idEsercizio: data.idEsercizio.present
          ? data.idEsercizio.value
          : this.idEsercizio,
      idEsercizioSuccessivo: data.idEsercizioSuccessivo.present
          ? data.idEsercizioSuccessivo.value
          : this.idEsercizioSuccessivo,
      tipoProgressione: data.tipoProgressione.present
          ? data.tipoProgressione.value
          : this.tipoProgressione,
      livelloMinimo: data.livelloMinimo.present
          ? data.livelloMinimo.value
          : this.livelloMinimo,
      priorita: data.priorita.present ? data.priorita.value : this.priorita,
      note: data.note.present ? data.note.value : this.note,
      attiva: data.attiva.present ? data.attiva.value : this.attiva,
      dataCreazione: data.dataCreazione.present
          ? data.dataCreazione.value
          : this.dataCreazione,
      dataModifica: data.dataModifica.present
          ? data.dataModifica.value
          : this.dataModifica,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProgressioniEserciziTableData(')
          ..write('id: $id, ')
          ..write('idEsercizio: $idEsercizio, ')
          ..write('idEsercizioSuccessivo: $idEsercizioSuccessivo, ')
          ..write('tipoProgressione: $tipoProgressione, ')
          ..write('livelloMinimo: $livelloMinimo, ')
          ..write('priorita: $priorita, ')
          ..write('note: $note, ')
          ..write('attiva: $attiva, ')
          ..write('dataCreazione: $dataCreazione, ')
          ..write('dataModifica: $dataModifica')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    idEsercizio,
    idEsercizioSuccessivo,
    tipoProgressione,
    livelloMinimo,
    priorita,
    note,
    attiva,
    dataCreazione,
    dataModifica,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProgressioniEserciziTableData &&
          other.id == this.id &&
          other.idEsercizio == this.idEsercizio &&
          other.idEsercizioSuccessivo == this.idEsercizioSuccessivo &&
          other.tipoProgressione == this.tipoProgressione &&
          other.livelloMinimo == this.livelloMinimo &&
          other.priorita == this.priorita &&
          other.note == this.note &&
          other.attiva == this.attiva &&
          other.dataCreazione == this.dataCreazione &&
          other.dataModifica == this.dataModifica);
}

class ProgressioniEserciziTableCompanion
    extends UpdateCompanion<ProgressioniEserciziTableData> {
  final Value<int> id;
  final Value<int> idEsercizio;
  final Value<int> idEsercizioSuccessivo;
  final Value<String> tipoProgressione;
  final Value<int> livelloMinimo;
  final Value<int> priorita;
  final Value<String?> note;
  final Value<bool> attiva;
  final Value<DateTime> dataCreazione;
  final Value<DateTime> dataModifica;
  const ProgressioniEserciziTableCompanion({
    this.id = const Value.absent(),
    this.idEsercizio = const Value.absent(),
    this.idEsercizioSuccessivo = const Value.absent(),
    this.tipoProgressione = const Value.absent(),
    this.livelloMinimo = const Value.absent(),
    this.priorita = const Value.absent(),
    this.note = const Value.absent(),
    this.attiva = const Value.absent(),
    this.dataCreazione = const Value.absent(),
    this.dataModifica = const Value.absent(),
  });
  ProgressioniEserciziTableCompanion.insert({
    this.id = const Value.absent(),
    required int idEsercizio,
    required int idEsercizioSuccessivo,
    required String tipoProgressione,
    required int livelloMinimo,
    this.priorita = const Value.absent(),
    this.note = const Value.absent(),
    this.attiva = const Value.absent(),
    required DateTime dataCreazione,
    required DateTime dataModifica,
  }) : idEsercizio = Value(idEsercizio),
       idEsercizioSuccessivo = Value(idEsercizioSuccessivo),
       tipoProgressione = Value(tipoProgressione),
       livelloMinimo = Value(livelloMinimo),
       dataCreazione = Value(dataCreazione),
       dataModifica = Value(dataModifica);
  static Insertable<ProgressioniEserciziTableData> custom({
    Expression<int>? id,
    Expression<int>? idEsercizio,
    Expression<int>? idEsercizioSuccessivo,
    Expression<String>? tipoProgressione,
    Expression<int>? livelloMinimo,
    Expression<int>? priorita,
    Expression<String>? note,
    Expression<bool>? attiva,
    Expression<DateTime>? dataCreazione,
    Expression<DateTime>? dataModifica,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (idEsercizio != null) 'id_esercizio': idEsercizio,
      if (idEsercizioSuccessivo != null)
        'id_esercizio_successivo': idEsercizioSuccessivo,
      if (tipoProgressione != null) 'tipo_progressione': tipoProgressione,
      if (livelloMinimo != null) 'livello_minimo': livelloMinimo,
      if (priorita != null) 'priorita': priorita,
      if (note != null) 'note': note,
      if (attiva != null) 'attiva': attiva,
      if (dataCreazione != null) 'data_creazione': dataCreazione,
      if (dataModifica != null) 'data_modifica': dataModifica,
    });
  }

  ProgressioniEserciziTableCompanion copyWith({
    Value<int>? id,
    Value<int>? idEsercizio,
    Value<int>? idEsercizioSuccessivo,
    Value<String>? tipoProgressione,
    Value<int>? livelloMinimo,
    Value<int>? priorita,
    Value<String?>? note,
    Value<bool>? attiva,
    Value<DateTime>? dataCreazione,
    Value<DateTime>? dataModifica,
  }) {
    return ProgressioniEserciziTableCompanion(
      id: id ?? this.id,
      idEsercizio: idEsercizio ?? this.idEsercizio,
      idEsercizioSuccessivo:
          idEsercizioSuccessivo ?? this.idEsercizioSuccessivo,
      tipoProgressione: tipoProgressione ?? this.tipoProgressione,
      livelloMinimo: livelloMinimo ?? this.livelloMinimo,
      priorita: priorita ?? this.priorita,
      note: note ?? this.note,
      attiva: attiva ?? this.attiva,
      dataCreazione: dataCreazione ?? this.dataCreazione,
      dataModifica: dataModifica ?? this.dataModifica,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (idEsercizio.present) {
      map['id_esercizio'] = Variable<int>(idEsercizio.value);
    }
    if (idEsercizioSuccessivo.present) {
      map['id_esercizio_successivo'] = Variable<int>(
        idEsercizioSuccessivo.value,
      );
    }
    if (tipoProgressione.present) {
      map['tipo_progressione'] = Variable<String>(tipoProgressione.value);
    }
    if (livelloMinimo.present) {
      map['livello_minimo'] = Variable<int>(livelloMinimo.value);
    }
    if (priorita.present) {
      map['priorita'] = Variable<int>(priorita.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (attiva.present) {
      map['attiva'] = Variable<bool>(attiva.value);
    }
    if (dataCreazione.present) {
      map['data_creazione'] = Variable<DateTime>(dataCreazione.value);
    }
    if (dataModifica.present) {
      map['data_modifica'] = Variable<DateTime>(dataModifica.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProgressioniEserciziTableCompanion(')
          ..write('id: $id, ')
          ..write('idEsercizio: $idEsercizio, ')
          ..write('idEsercizioSuccessivo: $idEsercizioSuccessivo, ')
          ..write('tipoProgressione: $tipoProgressione, ')
          ..write('livelloMinimo: $livelloMinimo, ')
          ..write('priorita: $priorita, ')
          ..write('note: $note, ')
          ..write('attiva: $attiva, ')
          ..write('dataCreazione: $dataCreazione, ')
          ..write('dataModifica: $dataModifica')
          ..write(')'))
        .toString();
  }
}

class $AlternativeEserciziTableTable extends AlternativeEserciziTable
    with
        TableInfo<
          $AlternativeEserciziTableTable,
          AlternativeEserciziTableData
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AlternativeEserciziTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _idEsercizioMeta = const VerificationMeta(
    'idEsercizio',
  );
  @override
  late final GeneratedColumn<int> idEsercizio = GeneratedColumn<int>(
    'id_esercizio',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES esercizi (id)',
    ),
  );
  static const VerificationMeta _idEsercizioAlternativoMeta =
      const VerificationMeta('idEsercizioAlternativo');
  @override
  late final GeneratedColumn<int> idEsercizioAlternativo = GeneratedColumn<int>(
    'id_esercizio_alternativo',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES esercizi (id)',
    ),
  );
  static const VerificationMeta _codiceMotivoMeta = const VerificationMeta(
    'codiceMotivo',
  );
  @override
  late final GeneratedColumn<String> codiceMotivo = GeneratedColumn<String>(
    'codice_motivo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _prioritaMeta = const VerificationMeta(
    'priorita',
  );
  @override
  late final GeneratedColumn<int> priorita = GeneratedColumn<int>(
    'priorita',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _attivaMeta = const VerificationMeta('attiva');
  @override
  late final GeneratedColumn<bool> attiva = GeneratedColumn<bool>(
    'attiva',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("attiva" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _dataCreazioneMeta = const VerificationMeta(
    'dataCreazione',
  );
  @override
  late final GeneratedColumn<DateTime> dataCreazione =
      GeneratedColumn<DateTime>(
        'data_creazione',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _dataModificaMeta = const VerificationMeta(
    'dataModifica',
  );
  @override
  late final GeneratedColumn<DateTime> dataModifica = GeneratedColumn<DateTime>(
    'data_modifica',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    idEsercizio,
    idEsercizioAlternativo,
    codiceMotivo,
    priorita,
    note,
    attiva,
    dataCreazione,
    dataModifica,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'alternative_esercizi';
  @override
  VerificationContext validateIntegrity(
    Insertable<AlternativeEserciziTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('id_esercizio')) {
      context.handle(
        _idEsercizioMeta,
        idEsercizio.isAcceptableOrUnknown(
          data['id_esercizio']!,
          _idEsercizioMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_idEsercizioMeta);
    }
    if (data.containsKey('id_esercizio_alternativo')) {
      context.handle(
        _idEsercizioAlternativoMeta,
        idEsercizioAlternativo.isAcceptableOrUnknown(
          data['id_esercizio_alternativo']!,
          _idEsercizioAlternativoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_idEsercizioAlternativoMeta);
    }
    if (data.containsKey('codice_motivo')) {
      context.handle(
        _codiceMotivoMeta,
        codiceMotivo.isAcceptableOrUnknown(
          data['codice_motivo']!,
          _codiceMotivoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_codiceMotivoMeta);
    }
    if (data.containsKey('priorita')) {
      context.handle(
        _prioritaMeta,
        priorita.isAcceptableOrUnknown(data['priorita']!, _prioritaMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('attiva')) {
      context.handle(
        _attivaMeta,
        attiva.isAcceptableOrUnknown(data['attiva']!, _attivaMeta),
      );
    }
    if (data.containsKey('data_creazione')) {
      context.handle(
        _dataCreazioneMeta,
        dataCreazione.isAcceptableOrUnknown(
          data['data_creazione']!,
          _dataCreazioneMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dataCreazioneMeta);
    }
    if (data.containsKey('data_modifica')) {
      context.handle(
        _dataModificaMeta,
        dataModifica.isAcceptableOrUnknown(
          data['data_modifica']!,
          _dataModificaMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dataModificaMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {idEsercizio, idEsercizioAlternativo, codiceMotivo},
  ];
  @override
  AlternativeEserciziTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AlternativeEserciziTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      idEsercizio: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id_esercizio'],
      )!,
      idEsercizioAlternativo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id_esercizio_alternativo'],
      )!,
      codiceMotivo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}codice_motivo'],
      )!,
      priorita: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}priorita'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      attiva: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}attiva'],
      )!,
      dataCreazione: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}data_creazione'],
      )!,
      dataModifica: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}data_modifica'],
      )!,
    );
  }

  @override
  $AlternativeEserciziTableTable createAlias(String alias) {
    return $AlternativeEserciziTableTable(attachedDatabase, alias);
  }
}

class AlternativeEserciziTableData extends DataClass
    implements Insertable<AlternativeEserciziTableData> {
  final int id;
  final int idEsercizio;
  final int idEsercizioAlternativo;

  /// Codice stabile di [ExerciseAlternativeReason].
  final String codiceMotivo;
  final int priorita;
  final String? note;
  final bool attiva;
  final DateTime dataCreazione;
  final DateTime dataModifica;
  const AlternativeEserciziTableData({
    required this.id,
    required this.idEsercizio,
    required this.idEsercizioAlternativo,
    required this.codiceMotivo,
    required this.priorita,
    this.note,
    required this.attiva,
    required this.dataCreazione,
    required this.dataModifica,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['id_esercizio'] = Variable<int>(idEsercizio);
    map['id_esercizio_alternativo'] = Variable<int>(idEsercizioAlternativo);
    map['codice_motivo'] = Variable<String>(codiceMotivo);
    map['priorita'] = Variable<int>(priorita);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['attiva'] = Variable<bool>(attiva);
    map['data_creazione'] = Variable<DateTime>(dataCreazione);
    map['data_modifica'] = Variable<DateTime>(dataModifica);
    return map;
  }

  AlternativeEserciziTableCompanion toCompanion(bool nullToAbsent) {
    return AlternativeEserciziTableCompanion(
      id: Value(id),
      idEsercizio: Value(idEsercizio),
      idEsercizioAlternativo: Value(idEsercizioAlternativo),
      codiceMotivo: Value(codiceMotivo),
      priorita: Value(priorita),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      attiva: Value(attiva),
      dataCreazione: Value(dataCreazione),
      dataModifica: Value(dataModifica),
    );
  }

  factory AlternativeEserciziTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AlternativeEserciziTableData(
      id: serializer.fromJson<int>(json['id']),
      idEsercizio: serializer.fromJson<int>(json['idEsercizio']),
      idEsercizioAlternativo: serializer.fromJson<int>(
        json['idEsercizioAlternativo'],
      ),
      codiceMotivo: serializer.fromJson<String>(json['codiceMotivo']),
      priorita: serializer.fromJson<int>(json['priorita']),
      note: serializer.fromJson<String?>(json['note']),
      attiva: serializer.fromJson<bool>(json['attiva']),
      dataCreazione: serializer.fromJson<DateTime>(json['dataCreazione']),
      dataModifica: serializer.fromJson<DateTime>(json['dataModifica']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'idEsercizio': serializer.toJson<int>(idEsercizio),
      'idEsercizioAlternativo': serializer.toJson<int>(idEsercizioAlternativo),
      'codiceMotivo': serializer.toJson<String>(codiceMotivo),
      'priorita': serializer.toJson<int>(priorita),
      'note': serializer.toJson<String?>(note),
      'attiva': serializer.toJson<bool>(attiva),
      'dataCreazione': serializer.toJson<DateTime>(dataCreazione),
      'dataModifica': serializer.toJson<DateTime>(dataModifica),
    };
  }

  AlternativeEserciziTableData copyWith({
    int? id,
    int? idEsercizio,
    int? idEsercizioAlternativo,
    String? codiceMotivo,
    int? priorita,
    Value<String?> note = const Value.absent(),
    bool? attiva,
    DateTime? dataCreazione,
    DateTime? dataModifica,
  }) => AlternativeEserciziTableData(
    id: id ?? this.id,
    idEsercizio: idEsercizio ?? this.idEsercizio,
    idEsercizioAlternativo:
        idEsercizioAlternativo ?? this.idEsercizioAlternativo,
    codiceMotivo: codiceMotivo ?? this.codiceMotivo,
    priorita: priorita ?? this.priorita,
    note: note.present ? note.value : this.note,
    attiva: attiva ?? this.attiva,
    dataCreazione: dataCreazione ?? this.dataCreazione,
    dataModifica: dataModifica ?? this.dataModifica,
  );
  AlternativeEserciziTableData copyWithCompanion(
    AlternativeEserciziTableCompanion data,
  ) {
    return AlternativeEserciziTableData(
      id: data.id.present ? data.id.value : this.id,
      idEsercizio: data.idEsercizio.present
          ? data.idEsercizio.value
          : this.idEsercizio,
      idEsercizioAlternativo: data.idEsercizioAlternativo.present
          ? data.idEsercizioAlternativo.value
          : this.idEsercizioAlternativo,
      codiceMotivo: data.codiceMotivo.present
          ? data.codiceMotivo.value
          : this.codiceMotivo,
      priorita: data.priorita.present ? data.priorita.value : this.priorita,
      note: data.note.present ? data.note.value : this.note,
      attiva: data.attiva.present ? data.attiva.value : this.attiva,
      dataCreazione: data.dataCreazione.present
          ? data.dataCreazione.value
          : this.dataCreazione,
      dataModifica: data.dataModifica.present
          ? data.dataModifica.value
          : this.dataModifica,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AlternativeEserciziTableData(')
          ..write('id: $id, ')
          ..write('idEsercizio: $idEsercizio, ')
          ..write('idEsercizioAlternativo: $idEsercizioAlternativo, ')
          ..write('codiceMotivo: $codiceMotivo, ')
          ..write('priorita: $priorita, ')
          ..write('note: $note, ')
          ..write('attiva: $attiva, ')
          ..write('dataCreazione: $dataCreazione, ')
          ..write('dataModifica: $dataModifica')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    idEsercizio,
    idEsercizioAlternativo,
    codiceMotivo,
    priorita,
    note,
    attiva,
    dataCreazione,
    dataModifica,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AlternativeEserciziTableData &&
          other.id == this.id &&
          other.idEsercizio == this.idEsercizio &&
          other.idEsercizioAlternativo == this.idEsercizioAlternativo &&
          other.codiceMotivo == this.codiceMotivo &&
          other.priorita == this.priorita &&
          other.note == this.note &&
          other.attiva == this.attiva &&
          other.dataCreazione == this.dataCreazione &&
          other.dataModifica == this.dataModifica);
}

class AlternativeEserciziTableCompanion
    extends UpdateCompanion<AlternativeEserciziTableData> {
  final Value<int> id;
  final Value<int> idEsercizio;
  final Value<int> idEsercizioAlternativo;
  final Value<String> codiceMotivo;
  final Value<int> priorita;
  final Value<String?> note;
  final Value<bool> attiva;
  final Value<DateTime> dataCreazione;
  final Value<DateTime> dataModifica;
  const AlternativeEserciziTableCompanion({
    this.id = const Value.absent(),
    this.idEsercizio = const Value.absent(),
    this.idEsercizioAlternativo = const Value.absent(),
    this.codiceMotivo = const Value.absent(),
    this.priorita = const Value.absent(),
    this.note = const Value.absent(),
    this.attiva = const Value.absent(),
    this.dataCreazione = const Value.absent(),
    this.dataModifica = const Value.absent(),
  });
  AlternativeEserciziTableCompanion.insert({
    this.id = const Value.absent(),
    required int idEsercizio,
    required int idEsercizioAlternativo,
    required String codiceMotivo,
    this.priorita = const Value.absent(),
    this.note = const Value.absent(),
    this.attiva = const Value.absent(),
    required DateTime dataCreazione,
    required DateTime dataModifica,
  }) : idEsercizio = Value(idEsercizio),
       idEsercizioAlternativo = Value(idEsercizioAlternativo),
       codiceMotivo = Value(codiceMotivo),
       dataCreazione = Value(dataCreazione),
       dataModifica = Value(dataModifica);
  static Insertable<AlternativeEserciziTableData> custom({
    Expression<int>? id,
    Expression<int>? idEsercizio,
    Expression<int>? idEsercizioAlternativo,
    Expression<String>? codiceMotivo,
    Expression<int>? priorita,
    Expression<String>? note,
    Expression<bool>? attiva,
    Expression<DateTime>? dataCreazione,
    Expression<DateTime>? dataModifica,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (idEsercizio != null) 'id_esercizio': idEsercizio,
      if (idEsercizioAlternativo != null)
        'id_esercizio_alternativo': idEsercizioAlternativo,
      if (codiceMotivo != null) 'codice_motivo': codiceMotivo,
      if (priorita != null) 'priorita': priorita,
      if (note != null) 'note': note,
      if (attiva != null) 'attiva': attiva,
      if (dataCreazione != null) 'data_creazione': dataCreazione,
      if (dataModifica != null) 'data_modifica': dataModifica,
    });
  }

  AlternativeEserciziTableCompanion copyWith({
    Value<int>? id,
    Value<int>? idEsercizio,
    Value<int>? idEsercizioAlternativo,
    Value<String>? codiceMotivo,
    Value<int>? priorita,
    Value<String?>? note,
    Value<bool>? attiva,
    Value<DateTime>? dataCreazione,
    Value<DateTime>? dataModifica,
  }) {
    return AlternativeEserciziTableCompanion(
      id: id ?? this.id,
      idEsercizio: idEsercizio ?? this.idEsercizio,
      idEsercizioAlternativo:
          idEsercizioAlternativo ?? this.idEsercizioAlternativo,
      codiceMotivo: codiceMotivo ?? this.codiceMotivo,
      priorita: priorita ?? this.priorita,
      note: note ?? this.note,
      attiva: attiva ?? this.attiva,
      dataCreazione: dataCreazione ?? this.dataCreazione,
      dataModifica: dataModifica ?? this.dataModifica,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (idEsercizio.present) {
      map['id_esercizio'] = Variable<int>(idEsercizio.value);
    }
    if (idEsercizioAlternativo.present) {
      map['id_esercizio_alternativo'] = Variable<int>(
        idEsercizioAlternativo.value,
      );
    }
    if (codiceMotivo.present) {
      map['codice_motivo'] = Variable<String>(codiceMotivo.value);
    }
    if (priorita.present) {
      map['priorita'] = Variable<int>(priorita.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (attiva.present) {
      map['attiva'] = Variable<bool>(attiva.value);
    }
    if (dataCreazione.present) {
      map['data_creazione'] = Variable<DateTime>(dataCreazione.value);
    }
    if (dataModifica.present) {
      map['data_modifica'] = Variable<DateTime>(dataModifica.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AlternativeEserciziTableCompanion(')
          ..write('id: $id, ')
          ..write('idEsercizio: $idEsercizio, ')
          ..write('idEsercizioAlternativo: $idEsercizioAlternativo, ')
          ..write('codiceMotivo: $codiceMotivo, ')
          ..write('priorita: $priorita, ')
          ..write('note: $note, ')
          ..write('attiva: $attiva, ')
          ..write('dataCreazione: $dataCreazione, ')
          ..write('dataModifica: $dataModifica')
          ..write(')'))
        .toString();
  }
}

class $VersioniCatalogoTableTable extends VersioniCatalogoTable
    with TableInfo<$VersioniCatalogoTableTable, VersioniCatalogoTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VersioniCatalogoTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _tipoCatalogoMeta = const VerificationMeta(
    'tipoCatalogo',
  );
  @override
  late final GeneratedColumn<String> tipoCatalogo = GeneratedColumn<String>(
    'tipo_catalogo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versioneMeta = const VerificationMeta(
    'versione',
  );
  @override
  late final GeneratedColumn<int> versione = GeneratedColumn<int>(
    'versione',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dataImportazioneMeta = const VerificationMeta(
    'dataImportazione',
  );
  @override
  late final GeneratedColumn<DateTime> dataImportazione =
      GeneratedColumn<DateTime>(
        'data_importazione',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _checksumMeta = const VerificationMeta(
    'checksum',
  );
  @override
  late final GeneratedColumn<String> checksum = GeneratedColumn<String>(
    'checksum',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tipoCatalogo,
    versione,
    dataImportazione,
    checksum,
    note,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'versioni_catalogo';
  @override
  VerificationContext validateIntegrity(
    Insertable<VersioniCatalogoTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('tipo_catalogo')) {
      context.handle(
        _tipoCatalogoMeta,
        tipoCatalogo.isAcceptableOrUnknown(
          data['tipo_catalogo']!,
          _tipoCatalogoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_tipoCatalogoMeta);
    }
    if (data.containsKey('versione')) {
      context.handle(
        _versioneMeta,
        versione.isAcceptableOrUnknown(data['versione']!, _versioneMeta),
      );
    } else if (isInserting) {
      context.missing(_versioneMeta);
    }
    if (data.containsKey('data_importazione')) {
      context.handle(
        _dataImportazioneMeta,
        dataImportazione.isAcceptableOrUnknown(
          data['data_importazione']!,
          _dataImportazioneMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dataImportazioneMeta);
    }
    if (data.containsKey('checksum')) {
      context.handle(
        _checksumMeta,
        checksum.isAcceptableOrUnknown(data['checksum']!, _checksumMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {tipoCatalogo, versione},
  ];
  @override
  VersioniCatalogoTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VersioniCatalogoTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      tipoCatalogo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tipo_catalogo'],
      )!,
      versione: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}versione'],
      )!,
      dataImportazione: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}data_importazione'],
      )!,
      checksum: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}checksum'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
    );
  }

  @override
  $VersioniCatalogoTableTable createAlias(String alias) {
    return $VersioniCatalogoTableTable(attachedDatabase, alias);
  }
}

class VersioniCatalogoTableData extends DataClass
    implements Insertable<VersioniCatalogoTableData> {
  final int id;
  final String tipoCatalogo;
  final int versione;
  final DateTime dataImportazione;
  final String? checksum;
  final String? note;
  const VersioniCatalogoTableData({
    required this.id,
    required this.tipoCatalogo,
    required this.versione,
    required this.dataImportazione,
    this.checksum,
    this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['tipo_catalogo'] = Variable<String>(tipoCatalogo);
    map['versione'] = Variable<int>(versione);
    map['data_importazione'] = Variable<DateTime>(dataImportazione);
    if (!nullToAbsent || checksum != null) {
      map['checksum'] = Variable<String>(checksum);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  VersioniCatalogoTableCompanion toCompanion(bool nullToAbsent) {
    return VersioniCatalogoTableCompanion(
      id: Value(id),
      tipoCatalogo: Value(tipoCatalogo),
      versione: Value(versione),
      dataImportazione: Value(dataImportazione),
      checksum: checksum == null && nullToAbsent
          ? const Value.absent()
          : Value(checksum),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory VersioniCatalogoTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VersioniCatalogoTableData(
      id: serializer.fromJson<int>(json['id']),
      tipoCatalogo: serializer.fromJson<String>(json['tipoCatalogo']),
      versione: serializer.fromJson<int>(json['versione']),
      dataImportazione: serializer.fromJson<DateTime>(json['dataImportazione']),
      checksum: serializer.fromJson<String?>(json['checksum']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'tipoCatalogo': serializer.toJson<String>(tipoCatalogo),
      'versione': serializer.toJson<int>(versione),
      'dataImportazione': serializer.toJson<DateTime>(dataImportazione),
      'checksum': serializer.toJson<String?>(checksum),
      'note': serializer.toJson<String?>(note),
    };
  }

  VersioniCatalogoTableData copyWith({
    int? id,
    String? tipoCatalogo,
    int? versione,
    DateTime? dataImportazione,
    Value<String?> checksum = const Value.absent(),
    Value<String?> note = const Value.absent(),
  }) => VersioniCatalogoTableData(
    id: id ?? this.id,
    tipoCatalogo: tipoCatalogo ?? this.tipoCatalogo,
    versione: versione ?? this.versione,
    dataImportazione: dataImportazione ?? this.dataImportazione,
    checksum: checksum.present ? checksum.value : this.checksum,
    note: note.present ? note.value : this.note,
  );
  VersioniCatalogoTableData copyWithCompanion(
    VersioniCatalogoTableCompanion data,
  ) {
    return VersioniCatalogoTableData(
      id: data.id.present ? data.id.value : this.id,
      tipoCatalogo: data.tipoCatalogo.present
          ? data.tipoCatalogo.value
          : this.tipoCatalogo,
      versione: data.versione.present ? data.versione.value : this.versione,
      dataImportazione: data.dataImportazione.present
          ? data.dataImportazione.value
          : this.dataImportazione,
      checksum: data.checksum.present ? data.checksum.value : this.checksum,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VersioniCatalogoTableData(')
          ..write('id: $id, ')
          ..write('tipoCatalogo: $tipoCatalogo, ')
          ..write('versione: $versione, ')
          ..write('dataImportazione: $dataImportazione, ')
          ..write('checksum: $checksum, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, tipoCatalogo, versione, dataImportazione, checksum, note);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VersioniCatalogoTableData &&
          other.id == this.id &&
          other.tipoCatalogo == this.tipoCatalogo &&
          other.versione == this.versione &&
          other.dataImportazione == this.dataImportazione &&
          other.checksum == this.checksum &&
          other.note == this.note);
}

class VersioniCatalogoTableCompanion
    extends UpdateCompanion<VersioniCatalogoTableData> {
  final Value<int> id;
  final Value<String> tipoCatalogo;
  final Value<int> versione;
  final Value<DateTime> dataImportazione;
  final Value<String?> checksum;
  final Value<String?> note;
  const VersioniCatalogoTableCompanion({
    this.id = const Value.absent(),
    this.tipoCatalogo = const Value.absent(),
    this.versione = const Value.absent(),
    this.dataImportazione = const Value.absent(),
    this.checksum = const Value.absent(),
    this.note = const Value.absent(),
  });
  VersioniCatalogoTableCompanion.insert({
    this.id = const Value.absent(),
    required String tipoCatalogo,
    required int versione,
    required DateTime dataImportazione,
    this.checksum = const Value.absent(),
    this.note = const Value.absent(),
  }) : tipoCatalogo = Value(tipoCatalogo),
       versione = Value(versione),
       dataImportazione = Value(dataImportazione);
  static Insertable<VersioniCatalogoTableData> custom({
    Expression<int>? id,
    Expression<String>? tipoCatalogo,
    Expression<int>? versione,
    Expression<DateTime>? dataImportazione,
    Expression<String>? checksum,
    Expression<String>? note,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tipoCatalogo != null) 'tipo_catalogo': tipoCatalogo,
      if (versione != null) 'versione': versione,
      if (dataImportazione != null) 'data_importazione': dataImportazione,
      if (checksum != null) 'checksum': checksum,
      if (note != null) 'note': note,
    });
  }

  VersioniCatalogoTableCompanion copyWith({
    Value<int>? id,
    Value<String>? tipoCatalogo,
    Value<int>? versione,
    Value<DateTime>? dataImportazione,
    Value<String?>? checksum,
    Value<String?>? note,
  }) {
    return VersioniCatalogoTableCompanion(
      id: id ?? this.id,
      tipoCatalogo: tipoCatalogo ?? this.tipoCatalogo,
      versione: versione ?? this.versione,
      dataImportazione: dataImportazione ?? this.dataImportazione,
      checksum: checksum ?? this.checksum,
      note: note ?? this.note,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (tipoCatalogo.present) {
      map['tipo_catalogo'] = Variable<String>(tipoCatalogo.value);
    }
    if (versione.present) {
      map['versione'] = Variable<int>(versione.value);
    }
    if (dataImportazione.present) {
      map['data_importazione'] = Variable<DateTime>(dataImportazione.value);
    }
    if (checksum.present) {
      map['checksum'] = Variable<String>(checksum.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VersioniCatalogoTableCompanion(')
          ..write('id: $id, ')
          ..write('tipoCatalogo: $tipoCatalogo, ')
          ..write('versione: $versione, ')
          ..write('dataImportazione: $dataImportazione, ')
          ..write('checksum: $checksum, ')
          ..write('note: $note')
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
  late final $CategorieEserciziTableTable categorieEserciziTable =
      $CategorieEserciziTableTable(this);
  late final $GruppiMuscolariTableTable gruppiMuscolariTable =
      $GruppiMuscolariTableTable(this);
  late final $EserciziTableTable eserciziTable = $EserciziTableTable(this);
  late final $EserciziGruppiMuscolariTableTable eserciziGruppiMuscolariTable =
      $EserciziGruppiMuscolariTableTable(this);
  late final $AttrezzatureTableTable attrezzatureTable =
      $AttrezzatureTableTable(this);
  late final $AttrezzatureEserciziTableTable attrezzatureEserciziTable =
      $AttrezzatureEserciziTableTable(this);
  late final $ImmaginiEserciziTableTable immaginiEserciziTable =
      $ImmaginiEserciziTableTable(this);
  late final $ProgressioniEserciziTableTable progressioniEserciziTable =
      $ProgressioniEserciziTableTable(this);
  late final $AlternativeEserciziTableTable alternativeEserciziTable =
      $AlternativeEserciziTableTable(this);
  late final $VersioniCatalogoTableTable versioniCatalogoTable =
      $VersioniCatalogoTableTable(this);
  late final Index idxEserciziIdCategoria = Index(
    'idx_esercizi_id_categoria',
    'CREATE INDEX idx_esercizi_id_categoria ON esercizi (id_categoria)',
  );
  late final Index idxEserciziLivelloMinimo = Index(
    'idx_esercizi_livello_minimo',
    'CREATE INDEX idx_esercizi_livello_minimo ON esercizi (livello_minimo)',
  );
  late final Index idxEserciziAttivo = Index(
    'idx_esercizi_attivo',
    'CREATE INDEX idx_esercizi_attivo ON esercizi (attivo)',
  );
  late final Index idxEgmIdEsercizio = Index(
    'idx_egm_id_esercizio',
    'CREATE INDEX idx_egm_id_esercizio ON esercizi_gruppi_muscolari (id_esercizio)',
  );
  late final Index idxEgmIdGruppoMuscolare = Index(
    'idx_egm_id_gruppo_muscolare',
    'CREATE INDEX idx_egm_id_gruppo_muscolare ON esercizi_gruppi_muscolari (id_gruppo_muscolare)',
  );
  late final Index idxAeIdEsercizio = Index(
    'idx_ae_id_esercizio',
    'CREATE INDEX idx_ae_id_esercizio ON attrezzature_esercizi (id_esercizio)',
  );
  late final Index idxAeIdAttrezzatura = Index(
    'idx_ae_id_attrezzatura',
    'CREATE INDEX idx_ae_id_attrezzatura ON attrezzature_esercizi (id_attrezzatura)',
  );
  late final Index idxImmaginiEserciziIdEsercizio = Index(
    'idx_immagini_esercizi_id_esercizio',
    'CREATE INDEX idx_immagini_esercizi_id_esercizio ON immagini_esercizi (id_esercizio)',
  );
  late final Index idxProgressioniIdEsercizio = Index(
    'idx_progressioni_id_esercizio',
    'CREATE INDEX idx_progressioni_id_esercizio ON progressioni_esercizi (id_esercizio)',
  );
  late final Index idxAlternativeIdEsercizio = Index(
    'idx_alternative_id_esercizio',
    'CREATE INDEX idx_alternative_id_esercizio ON alternative_esercizi (id_esercizio)',
  );
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
  late final CategorieEserciziDao categorieEserciziDao = CategorieEserciziDao(
    this as AppDatabase,
  );
  late final GruppiMuscolariDao gruppiMuscolariDao = GruppiMuscolariDao(
    this as AppDatabase,
  );
  late final AttrezzatureDao attrezzatureDao = AttrezzatureDao(
    this as AppDatabase,
  );
  late final EserciziDao eserciziDao = EserciziDao(this as AppDatabase);
  late final ImmaginiEserciziDao immaginiEserciziDao = ImmaginiEserciziDao(
    this as AppDatabase,
  );
  late final ProgressioniEserciziDao progressioniEserciziDao =
      ProgressioniEserciziDao(this as AppDatabase);
  late final AlternativeEserciziDao alternativeEserciziDao =
      AlternativeEserciziDao(this as AppDatabase);
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
    categorieEserciziTable,
    gruppiMuscolariTable,
    eserciziTable,
    eserciziGruppiMuscolariTable,
    attrezzatureTable,
    attrezzatureEserciziTable,
    immaginiEserciziTable,
    progressioniEserciziTable,
    alternativeEserciziTable,
    versioniCatalogoTable,
    idxEserciziIdCategoria,
    idxEserciziLivelloMinimo,
    idxEserciziAttivo,
    idxEgmIdEsercizio,
    idxEgmIdGruppoMuscolare,
    idxAeIdEsercizio,
    idxAeIdAttrezzatura,
    idxImmaginiEserciziIdEsercizio,
    idxProgressioniIdEsercizio,
    idxAlternativeIdEsercizio,
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
        aliasName: 'profili_utente__id__misurazioni_corporee__profile_id',
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
        aliasName: 'profili_utente__id__misurazioni_pressione__profile_id',
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
        aliasName: 'profili_utente__id__attrezzature_utente__profile_id',
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

  static $UserProfilesTableTable _profileIdTable(_$AppDatabase db) => db
      .userProfilesTable
      .createAlias('misurazioni_corporee__profile_id__profili_utente__id');

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

  static $UserProfilesTableTable _profileIdTable(_$AppDatabase db) => db
      .userProfilesTable
      .createAlias('misurazioni_pressione__profile_id__profili_utente__id');

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
      .createAlias('attrezzature_utente__profile_id__profili_utente__id');

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
typedef $$CategorieEserciziTableTableCreateCompanionBuilder =
    CategorieEserciziTableCompanion Function({
      Value<int> id,
      required String codice,
      required String nome,
      Value<String?> descrizione,
      Value<int> ordineVisualizzazione,
      Value<bool> attiva,
      required DateTime dataCreazione,
      required DateTime dataModifica,
    });
typedef $$CategorieEserciziTableTableUpdateCompanionBuilder =
    CategorieEserciziTableCompanion Function({
      Value<int> id,
      Value<String> codice,
      Value<String> nome,
      Value<String?> descrizione,
      Value<int> ordineVisualizzazione,
      Value<bool> attiva,
      Value<DateTime> dataCreazione,
      Value<DateTime> dataModifica,
    });

final class $$CategorieEserciziTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $CategorieEserciziTableTable,
          CategorieEserciziTableData
        > {
  $$CategorieEserciziTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$EserciziTableTable, List<EserciziTableData>>
  _eserciziTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.eserciziTable,
    aliasName: 'categorie_esercizi__id__esercizi__id_categoria',
  );

  $$EserciziTableTableProcessedTableManager get eserciziTableRefs {
    final manager = $$EserciziTableTableTableManager(
      $_db,
      $_db.eserciziTable,
    ).filter((f) => f.idCategoria.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_eserciziTableRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CategorieEserciziTableTableFilterComposer
    extends Composer<_$AppDatabase, $CategorieEserciziTableTable> {
  $$CategorieEserciziTableTableFilterComposer({
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

  ColumnFilters<String> get codice => $composableBuilder(
    column: $table.codice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get descrizione => $composableBuilder(
    column: $table.descrizione,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ordineVisualizzazione => $composableBuilder(
    column: $table.ordineVisualizzazione,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get attiva => $composableBuilder(
    column: $table.attiva,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dataCreazione => $composableBuilder(
    column: $table.dataCreazione,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dataModifica => $composableBuilder(
    column: $table.dataModifica,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> eserciziTableRefs(
    Expression<bool> Function($$EserciziTableTableFilterComposer f) f,
  ) {
    final $$EserciziTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.eserciziTable,
      getReferencedColumn: (t) => t.idCategoria,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EserciziTableTableFilterComposer(
            $db: $db,
            $table: $db.eserciziTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategorieEserciziTableTableOrderingComposer
    extends Composer<_$AppDatabase, $CategorieEserciziTableTable> {
  $$CategorieEserciziTableTableOrderingComposer({
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

  ColumnOrderings<String> get codice => $composableBuilder(
    column: $table.codice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get descrizione => $composableBuilder(
    column: $table.descrizione,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ordineVisualizzazione => $composableBuilder(
    column: $table.ordineVisualizzazione,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get attiva => $composableBuilder(
    column: $table.attiva,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dataCreazione => $composableBuilder(
    column: $table.dataCreazione,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dataModifica => $composableBuilder(
    column: $table.dataModifica,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategorieEserciziTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategorieEserciziTableTable> {
  $$CategorieEserciziTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get codice =>
      $composableBuilder(column: $table.codice, builder: (column) => column);

  GeneratedColumn<String> get nome =>
      $composableBuilder(column: $table.nome, builder: (column) => column);

  GeneratedColumn<String> get descrizione => $composableBuilder(
    column: $table.descrizione,
    builder: (column) => column,
  );

  GeneratedColumn<int> get ordineVisualizzazione => $composableBuilder(
    column: $table.ordineVisualizzazione,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get attiva =>
      $composableBuilder(column: $table.attiva, builder: (column) => column);

  GeneratedColumn<DateTime> get dataCreazione => $composableBuilder(
    column: $table.dataCreazione,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dataModifica => $composableBuilder(
    column: $table.dataModifica,
    builder: (column) => column,
  );

  Expression<T> eserciziTableRefs<T extends Object>(
    Expression<T> Function($$EserciziTableTableAnnotationComposer a) f,
  ) {
    final $$EserciziTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.eserciziTable,
      getReferencedColumn: (t) => t.idCategoria,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EserciziTableTableAnnotationComposer(
            $db: $db,
            $table: $db.eserciziTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategorieEserciziTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategorieEserciziTableTable,
          CategorieEserciziTableData,
          $$CategorieEserciziTableTableFilterComposer,
          $$CategorieEserciziTableTableOrderingComposer,
          $$CategorieEserciziTableTableAnnotationComposer,
          $$CategorieEserciziTableTableCreateCompanionBuilder,
          $$CategorieEserciziTableTableUpdateCompanionBuilder,
          (CategorieEserciziTableData, $$CategorieEserciziTableTableReferences),
          CategorieEserciziTableData,
          PrefetchHooks Function({bool eserciziTableRefs})
        > {
  $$CategorieEserciziTableTableTableManager(
    _$AppDatabase db,
    $CategorieEserciziTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategorieEserciziTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$CategorieEserciziTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CategorieEserciziTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> codice = const Value.absent(),
                Value<String> nome = const Value.absent(),
                Value<String?> descrizione = const Value.absent(),
                Value<int> ordineVisualizzazione = const Value.absent(),
                Value<bool> attiva = const Value.absent(),
                Value<DateTime> dataCreazione = const Value.absent(),
                Value<DateTime> dataModifica = const Value.absent(),
              }) => CategorieEserciziTableCompanion(
                id: id,
                codice: codice,
                nome: nome,
                descrizione: descrizione,
                ordineVisualizzazione: ordineVisualizzazione,
                attiva: attiva,
                dataCreazione: dataCreazione,
                dataModifica: dataModifica,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String codice,
                required String nome,
                Value<String?> descrizione = const Value.absent(),
                Value<int> ordineVisualizzazione = const Value.absent(),
                Value<bool> attiva = const Value.absent(),
                required DateTime dataCreazione,
                required DateTime dataModifica,
              }) => CategorieEserciziTableCompanion.insert(
                id: id,
                codice: codice,
                nome: nome,
                descrizione: descrizione,
                ordineVisualizzazione: ordineVisualizzazione,
                attiva: attiva,
                dataCreazione: dataCreazione,
                dataModifica: dataModifica,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CategorieEserciziTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({eserciziTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (eserciziTableRefs) db.eserciziTable,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (eserciziTableRefs)
                    await $_getPrefetchedData<
                      CategorieEserciziTableData,
                      $CategorieEserciziTableTable,
                      EserciziTableData
                    >(
                      currentTable: table,
                      referencedTable: $$CategorieEserciziTableTableReferences
                          ._eserciziTableRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$CategorieEserciziTableTableReferences(
                            db,
                            table,
                            p0,
                          ).eserciziTableRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.idCategoria == item.id,
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

typedef $$CategorieEserciziTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategorieEserciziTableTable,
      CategorieEserciziTableData,
      $$CategorieEserciziTableTableFilterComposer,
      $$CategorieEserciziTableTableOrderingComposer,
      $$CategorieEserciziTableTableAnnotationComposer,
      $$CategorieEserciziTableTableCreateCompanionBuilder,
      $$CategorieEserciziTableTableUpdateCompanionBuilder,
      (CategorieEserciziTableData, $$CategorieEserciziTableTableReferences),
      CategorieEserciziTableData,
      PrefetchHooks Function({bool eserciziTableRefs})
    >;
typedef $$GruppiMuscolariTableTableCreateCompanionBuilder =
    GruppiMuscolariTableCompanion Function({
      Value<int> id,
      required String codice,
      required String nome,
      Value<String?> descrizione,
      Value<bool> attivo,
      required DateTime dataCreazione,
      required DateTime dataModifica,
    });
typedef $$GruppiMuscolariTableTableUpdateCompanionBuilder =
    GruppiMuscolariTableCompanion Function({
      Value<int> id,
      Value<String> codice,
      Value<String> nome,
      Value<String?> descrizione,
      Value<bool> attivo,
      Value<DateTime> dataCreazione,
      Value<DateTime> dataModifica,
    });

final class $$GruppiMuscolariTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $GruppiMuscolariTableTable,
          GruppiMuscolariTableData
        > {
  $$GruppiMuscolariTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<
    $EserciziGruppiMuscolariTableTable,
    List<EserciziGruppiMuscolariTableData>
  >
  _eserciziGruppiMuscolariTableRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.eserciziGruppiMuscolariTable,
    aliasName:
        'gruppi_muscolari__id__esercizi_gruppi_muscolari__id_gruppo_muscolare',
  );

  $$EserciziGruppiMuscolariTableTableProcessedTableManager
  get eserciziGruppiMuscolariTableRefs {
    final manager = $$EserciziGruppiMuscolariTableTableTableManager(
      $_db,
      $_db.eserciziGruppiMuscolariTable,
    ).filter((f) => f.idGruppoMuscolare.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _eserciziGruppiMuscolariTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$GruppiMuscolariTableTableFilterComposer
    extends Composer<_$AppDatabase, $GruppiMuscolariTableTable> {
  $$GruppiMuscolariTableTableFilterComposer({
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

  ColumnFilters<String> get codice => $composableBuilder(
    column: $table.codice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get descrizione => $composableBuilder(
    column: $table.descrizione,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get attivo => $composableBuilder(
    column: $table.attivo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dataCreazione => $composableBuilder(
    column: $table.dataCreazione,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dataModifica => $composableBuilder(
    column: $table.dataModifica,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> eserciziGruppiMuscolariTableRefs(
    Expression<bool> Function(
      $$EserciziGruppiMuscolariTableTableFilterComposer f,
    )
    f,
  ) {
    final $$EserciziGruppiMuscolariTableTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.eserciziGruppiMuscolariTable,
          getReferencedColumn: (t) => t.idGruppoMuscolare,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$EserciziGruppiMuscolariTableTableFilterComposer(
                $db: $db,
                $table: $db.eserciziGruppiMuscolariTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$GruppiMuscolariTableTableOrderingComposer
    extends Composer<_$AppDatabase, $GruppiMuscolariTableTable> {
  $$GruppiMuscolariTableTableOrderingComposer({
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

  ColumnOrderings<String> get codice => $composableBuilder(
    column: $table.codice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get descrizione => $composableBuilder(
    column: $table.descrizione,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get attivo => $composableBuilder(
    column: $table.attivo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dataCreazione => $composableBuilder(
    column: $table.dataCreazione,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dataModifica => $composableBuilder(
    column: $table.dataModifica,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GruppiMuscolariTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $GruppiMuscolariTableTable> {
  $$GruppiMuscolariTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get codice =>
      $composableBuilder(column: $table.codice, builder: (column) => column);

  GeneratedColumn<String> get nome =>
      $composableBuilder(column: $table.nome, builder: (column) => column);

  GeneratedColumn<String> get descrizione => $composableBuilder(
    column: $table.descrizione,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get attivo =>
      $composableBuilder(column: $table.attivo, builder: (column) => column);

  GeneratedColumn<DateTime> get dataCreazione => $composableBuilder(
    column: $table.dataCreazione,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dataModifica => $composableBuilder(
    column: $table.dataModifica,
    builder: (column) => column,
  );

  Expression<T> eserciziGruppiMuscolariTableRefs<T extends Object>(
    Expression<T> Function(
      $$EserciziGruppiMuscolariTableTableAnnotationComposer a,
    )
    f,
  ) {
    final $$EserciziGruppiMuscolariTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.eserciziGruppiMuscolariTable,
          getReferencedColumn: (t) => t.idGruppoMuscolare,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$EserciziGruppiMuscolariTableTableAnnotationComposer(
                $db: $db,
                $table: $db.eserciziGruppiMuscolariTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$GruppiMuscolariTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GruppiMuscolariTableTable,
          GruppiMuscolariTableData,
          $$GruppiMuscolariTableTableFilterComposer,
          $$GruppiMuscolariTableTableOrderingComposer,
          $$GruppiMuscolariTableTableAnnotationComposer,
          $$GruppiMuscolariTableTableCreateCompanionBuilder,
          $$GruppiMuscolariTableTableUpdateCompanionBuilder,
          (GruppiMuscolariTableData, $$GruppiMuscolariTableTableReferences),
          GruppiMuscolariTableData,
          PrefetchHooks Function({bool eserciziGruppiMuscolariTableRefs})
        > {
  $$GruppiMuscolariTableTableTableManager(
    _$AppDatabase db,
    $GruppiMuscolariTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GruppiMuscolariTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GruppiMuscolariTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$GruppiMuscolariTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> codice = const Value.absent(),
                Value<String> nome = const Value.absent(),
                Value<String?> descrizione = const Value.absent(),
                Value<bool> attivo = const Value.absent(),
                Value<DateTime> dataCreazione = const Value.absent(),
                Value<DateTime> dataModifica = const Value.absent(),
              }) => GruppiMuscolariTableCompanion(
                id: id,
                codice: codice,
                nome: nome,
                descrizione: descrizione,
                attivo: attivo,
                dataCreazione: dataCreazione,
                dataModifica: dataModifica,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String codice,
                required String nome,
                Value<String?> descrizione = const Value.absent(),
                Value<bool> attivo = const Value.absent(),
                required DateTime dataCreazione,
                required DateTime dataModifica,
              }) => GruppiMuscolariTableCompanion.insert(
                id: id,
                codice: codice,
                nome: nome,
                descrizione: descrizione,
                attivo: attivo,
                dataCreazione: dataCreazione,
                dataModifica: dataModifica,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$GruppiMuscolariTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({eserciziGruppiMuscolariTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (eserciziGruppiMuscolariTableRefs)
                  db.eserciziGruppiMuscolariTable,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (eserciziGruppiMuscolariTableRefs)
                    await $_getPrefetchedData<
                      GruppiMuscolariTableData,
                      $GruppiMuscolariTableTable,
                      EserciziGruppiMuscolariTableData
                    >(
                      currentTable: table,
                      referencedTable: $$GruppiMuscolariTableTableReferences
                          ._eserciziGruppiMuscolariTableRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$GruppiMuscolariTableTableReferences(
                            db,
                            table,
                            p0,
                          ).eserciziGruppiMuscolariTableRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.idGruppoMuscolare == item.id,
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

typedef $$GruppiMuscolariTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GruppiMuscolariTableTable,
      GruppiMuscolariTableData,
      $$GruppiMuscolariTableTableFilterComposer,
      $$GruppiMuscolariTableTableOrderingComposer,
      $$GruppiMuscolariTableTableAnnotationComposer,
      $$GruppiMuscolariTableTableCreateCompanionBuilder,
      $$GruppiMuscolariTableTableUpdateCompanionBuilder,
      (GruppiMuscolariTableData, $$GruppiMuscolariTableTableReferences),
      GruppiMuscolariTableData,
      PrefetchHooks Function({bool eserciziGruppiMuscolariTableRefs})
    >;
typedef $$EserciziTableTableCreateCompanionBuilder =
    EserciziTableCompanion Function({
      Value<int> id,
      required String codice,
      required String nome,
      required String descrizione,
      required String istruzioni,
      Value<String?> istruzioniRespirazione,
      Value<String?> noteSicurezza,
      Value<String?> erroriComuni,
      required int idCategoria,
      required int livelloMinimo,
      Value<int?> livelloMassimo,
      required String livelloImpatto,
      Value<String?> intensitaCardio,
      Value<bool> richiedeEquilibrio,
      Value<bool> richiedePavimento,
      Value<bool> richiedePosizioneEretta,
      Value<bool> supportoConsentito,
      Value<int?> seriePredefinite,
      Value<int?> ripetizioniPredefinite,
      Value<int?> durataPredefinitaSecondi,
      Value<int?> recuperoPredefinitoSecondi,
      Value<bool> esercizioSistema,
      Value<bool> attivo,
      required int versioneCatalogo,
      required DateTime dataCreazione,
      required DateTime dataModifica,
    });
typedef $$EserciziTableTableUpdateCompanionBuilder =
    EserciziTableCompanion Function({
      Value<int> id,
      Value<String> codice,
      Value<String> nome,
      Value<String> descrizione,
      Value<String> istruzioni,
      Value<String?> istruzioniRespirazione,
      Value<String?> noteSicurezza,
      Value<String?> erroriComuni,
      Value<int> idCategoria,
      Value<int> livelloMinimo,
      Value<int?> livelloMassimo,
      Value<String> livelloImpatto,
      Value<String?> intensitaCardio,
      Value<bool> richiedeEquilibrio,
      Value<bool> richiedePavimento,
      Value<bool> richiedePosizioneEretta,
      Value<bool> supportoConsentito,
      Value<int?> seriePredefinite,
      Value<int?> ripetizioniPredefinite,
      Value<int?> durataPredefinitaSecondi,
      Value<int?> recuperoPredefinitoSecondi,
      Value<bool> esercizioSistema,
      Value<bool> attivo,
      Value<int> versioneCatalogo,
      Value<DateTime> dataCreazione,
      Value<DateTime> dataModifica,
    });

final class $$EserciziTableTableReferences
    extends
        BaseReferences<_$AppDatabase, $EserciziTableTable, EserciziTableData> {
  $$EserciziTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CategorieEserciziTableTable _idCategoriaTable(_$AppDatabase db) => db
      .categorieEserciziTable
      .createAlias('esercizi__id_categoria__categorie_esercizi__id');

  $$CategorieEserciziTableTableProcessedTableManager get idCategoria {
    final $_column = $_itemColumn<int>('id_categoria')!;

    final manager = $$CategorieEserciziTableTableTableManager(
      $_db,
      $_db.categorieEserciziTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_idCategoriaTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $EserciziGruppiMuscolariTableTable,
    List<EserciziGruppiMuscolariTableData>
  >
  _eserciziGruppiMuscolariTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.eserciziGruppiMuscolariTable,
        aliasName: 'esercizi__id__esercizi_gruppi_muscolari__id_esercizio',
      );

  $$EserciziGruppiMuscolariTableTableProcessedTableManager
  get eserciziGruppiMuscolariTableRefs {
    final manager = $$EserciziGruppiMuscolariTableTableTableManager(
      $_db,
      $_db.eserciziGruppiMuscolariTable,
    ).filter((f) => f.idEsercizio.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _eserciziGruppiMuscolariTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $AttrezzatureEserciziTableTable,
    List<AttrezzatureEserciziTableData>
  >
  _attrezzatureEserciziTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.attrezzatureEserciziTable,
        aliasName: 'esercizi__id__attrezzature_esercizi__id_esercizio',
      );

  $$AttrezzatureEserciziTableTableProcessedTableManager
  get attrezzatureEserciziTableRefs {
    final manager = $$AttrezzatureEserciziTableTableTableManager(
      $_db,
      $_db.attrezzatureEserciziTable,
    ).filter((f) => f.idEsercizio.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _attrezzatureEserciziTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $ImmaginiEserciziTableTable,
    List<ImmaginiEserciziTableData>
  >
  _immaginiEserciziTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.immaginiEserciziTable,
        aliasName: 'esercizi__id__immagini_esercizi__id_esercizio',
      );

  $$ImmaginiEserciziTableTableProcessedTableManager
  get immaginiEserciziTableRefs {
    final manager = $$ImmaginiEserciziTableTableTableManager(
      $_db,
      $_db.immaginiEserciziTable,
    ).filter((f) => f.idEsercizio.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _immaginiEserciziTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $ProgressioniEserciziTableTable,
    List<ProgressioniEserciziTableData>
  >
  _progressioniComePrecedenteTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.progressioniEserciziTable,
        aliasName: 'esercizi__id__progressioni_esercizi__id_esercizio',
      );

  $$ProgressioniEserciziTableTableProcessedTableManager
  get progressioniComePrecedente {
    final manager = $$ProgressioniEserciziTableTableTableManager(
      $_db,
      $_db.progressioniEserciziTable,
    ).filter((f) => f.idEsercizio.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _progressioniComePrecedenteTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $ProgressioniEserciziTableTable,
    List<ProgressioniEserciziTableData>
  >
  _progressioniComeSuccessivoTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.progressioniEserciziTable,
        aliasName:
            'esercizi__id__progressioni_esercizi__id_esercizio_successivo',
      );

  $$ProgressioniEserciziTableTableProcessedTableManager
  get progressioniComeSuccessivo {
    final manager =
        $$ProgressioniEserciziTableTableTableManager(
          $_db,
          $_db.progressioniEserciziTable,
        ).filter(
          (f) => f.idEsercizioSuccessivo.id.sqlEquals($_itemColumn<int>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _progressioniComeSuccessivoTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $AlternativeEserciziTableTable,
    List<AlternativeEserciziTableData>
  >
  _alternativeComeOriginaleTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.alternativeEserciziTable,
        aliasName: 'esercizi__id__alternative_esercizi__id_esercizio',
      );

  $$AlternativeEserciziTableTableProcessedTableManager
  get alternativeComeOriginale {
    final manager = $$AlternativeEserciziTableTableTableManager(
      $_db,
      $_db.alternativeEserciziTable,
    ).filter((f) => f.idEsercizio.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _alternativeComeOriginaleTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $AlternativeEserciziTableTable,
    List<AlternativeEserciziTableData>
  >
  _alternativeComeAlternativaTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.alternativeEserciziTable,
        aliasName:
            'esercizi__id__alternative_esercizi__id_esercizio_alternativo',
      );

  $$AlternativeEserciziTableTableProcessedTableManager
  get alternativeComeAlternativa {
    final manager =
        $$AlternativeEserciziTableTableTableManager(
          $_db,
          $_db.alternativeEserciziTable,
        ).filter(
          (f) =>
              f.idEsercizioAlternativo.id.sqlEquals($_itemColumn<int>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _alternativeComeAlternativaTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$EserciziTableTableFilterComposer
    extends Composer<_$AppDatabase, $EserciziTableTable> {
  $$EserciziTableTableFilterComposer({
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

  ColumnFilters<String> get codice => $composableBuilder(
    column: $table.codice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get descrizione => $composableBuilder(
    column: $table.descrizione,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get istruzioni => $composableBuilder(
    column: $table.istruzioni,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get istruzioniRespirazione => $composableBuilder(
    column: $table.istruzioniRespirazione,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get noteSicurezza => $composableBuilder(
    column: $table.noteSicurezza,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get erroriComuni => $composableBuilder(
    column: $table.erroriComuni,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get livelloMinimo => $composableBuilder(
    column: $table.livelloMinimo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get livelloMassimo => $composableBuilder(
    column: $table.livelloMassimo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get livelloImpatto => $composableBuilder(
    column: $table.livelloImpatto,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get intensitaCardio => $composableBuilder(
    column: $table.intensitaCardio,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get richiedeEquilibrio => $composableBuilder(
    column: $table.richiedeEquilibrio,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get richiedePavimento => $composableBuilder(
    column: $table.richiedePavimento,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get richiedePosizioneEretta => $composableBuilder(
    column: $table.richiedePosizioneEretta,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get supportoConsentito => $composableBuilder(
    column: $table.supportoConsentito,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get seriePredefinite => $composableBuilder(
    column: $table.seriePredefinite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ripetizioniPredefinite => $composableBuilder(
    column: $table.ripetizioniPredefinite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durataPredefinitaSecondi => $composableBuilder(
    column: $table.durataPredefinitaSecondi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get recuperoPredefinitoSecondi => $composableBuilder(
    column: $table.recuperoPredefinitoSecondi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get esercizioSistema => $composableBuilder(
    column: $table.esercizioSistema,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get attivo => $composableBuilder(
    column: $table.attivo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get versioneCatalogo => $composableBuilder(
    column: $table.versioneCatalogo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dataCreazione => $composableBuilder(
    column: $table.dataCreazione,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dataModifica => $composableBuilder(
    column: $table.dataModifica,
    builder: (column) => ColumnFilters(column),
  );

  $$CategorieEserciziTableTableFilterComposer get idCategoria {
    final $$CategorieEserciziTableTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.idCategoria,
          referencedTable: $db.categorieEserciziTable,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CategorieEserciziTableTableFilterComposer(
                $db: $db,
                $table: $db.categorieEserciziTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  Expression<bool> eserciziGruppiMuscolariTableRefs(
    Expression<bool> Function(
      $$EserciziGruppiMuscolariTableTableFilterComposer f,
    )
    f,
  ) {
    final $$EserciziGruppiMuscolariTableTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.eserciziGruppiMuscolariTable,
          getReferencedColumn: (t) => t.idEsercizio,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$EserciziGruppiMuscolariTableTableFilterComposer(
                $db: $db,
                $table: $db.eserciziGruppiMuscolariTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> attrezzatureEserciziTableRefs(
    Expression<bool> Function($$AttrezzatureEserciziTableTableFilterComposer f)
    f,
  ) {
    final $$AttrezzatureEserciziTableTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.attrezzatureEserciziTable,
          getReferencedColumn: (t) => t.idEsercizio,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$AttrezzatureEserciziTableTableFilterComposer(
                $db: $db,
                $table: $db.attrezzatureEserciziTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> immaginiEserciziTableRefs(
    Expression<bool> Function($$ImmaginiEserciziTableTableFilterComposer f) f,
  ) {
    final $$ImmaginiEserciziTableTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.immaginiEserciziTable,
          getReferencedColumn: (t) => t.idEsercizio,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ImmaginiEserciziTableTableFilterComposer(
                $db: $db,
                $table: $db.immaginiEserciziTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> progressioniComePrecedente(
    Expression<bool> Function($$ProgressioniEserciziTableTableFilterComposer f)
    f,
  ) {
    final $$ProgressioniEserciziTableTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.progressioniEserciziTable,
          getReferencedColumn: (t) => t.idEsercizio,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ProgressioniEserciziTableTableFilterComposer(
                $db: $db,
                $table: $db.progressioniEserciziTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> progressioniComeSuccessivo(
    Expression<bool> Function($$ProgressioniEserciziTableTableFilterComposer f)
    f,
  ) {
    final $$ProgressioniEserciziTableTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.progressioniEserciziTable,
          getReferencedColumn: (t) => t.idEsercizioSuccessivo,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ProgressioniEserciziTableTableFilterComposer(
                $db: $db,
                $table: $db.progressioniEserciziTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> alternativeComeOriginale(
    Expression<bool> Function($$AlternativeEserciziTableTableFilterComposer f)
    f,
  ) {
    final $$AlternativeEserciziTableTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.alternativeEserciziTable,
          getReferencedColumn: (t) => t.idEsercizio,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$AlternativeEserciziTableTableFilterComposer(
                $db: $db,
                $table: $db.alternativeEserciziTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> alternativeComeAlternativa(
    Expression<bool> Function($$AlternativeEserciziTableTableFilterComposer f)
    f,
  ) {
    final $$AlternativeEserciziTableTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.alternativeEserciziTable,
          getReferencedColumn: (t) => t.idEsercizioAlternativo,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$AlternativeEserciziTableTableFilterComposer(
                $db: $db,
                $table: $db.alternativeEserciziTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$EserciziTableTableOrderingComposer
    extends Composer<_$AppDatabase, $EserciziTableTable> {
  $$EserciziTableTableOrderingComposer({
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

  ColumnOrderings<String> get codice => $composableBuilder(
    column: $table.codice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get descrizione => $composableBuilder(
    column: $table.descrizione,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get istruzioni => $composableBuilder(
    column: $table.istruzioni,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get istruzioniRespirazione => $composableBuilder(
    column: $table.istruzioniRespirazione,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get noteSicurezza => $composableBuilder(
    column: $table.noteSicurezza,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get erroriComuni => $composableBuilder(
    column: $table.erroriComuni,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get livelloMinimo => $composableBuilder(
    column: $table.livelloMinimo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get livelloMassimo => $composableBuilder(
    column: $table.livelloMassimo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get livelloImpatto => $composableBuilder(
    column: $table.livelloImpatto,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get intensitaCardio => $composableBuilder(
    column: $table.intensitaCardio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get richiedeEquilibrio => $composableBuilder(
    column: $table.richiedeEquilibrio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get richiedePavimento => $composableBuilder(
    column: $table.richiedePavimento,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get richiedePosizioneEretta => $composableBuilder(
    column: $table.richiedePosizioneEretta,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get supportoConsentito => $composableBuilder(
    column: $table.supportoConsentito,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get seriePredefinite => $composableBuilder(
    column: $table.seriePredefinite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ripetizioniPredefinite => $composableBuilder(
    column: $table.ripetizioniPredefinite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durataPredefinitaSecondi => $composableBuilder(
    column: $table.durataPredefinitaSecondi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get recuperoPredefinitoSecondi => $composableBuilder(
    column: $table.recuperoPredefinitoSecondi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get esercizioSistema => $composableBuilder(
    column: $table.esercizioSistema,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get attivo => $composableBuilder(
    column: $table.attivo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get versioneCatalogo => $composableBuilder(
    column: $table.versioneCatalogo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dataCreazione => $composableBuilder(
    column: $table.dataCreazione,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dataModifica => $composableBuilder(
    column: $table.dataModifica,
    builder: (column) => ColumnOrderings(column),
  );

  $$CategorieEserciziTableTableOrderingComposer get idCategoria {
    final $$CategorieEserciziTableTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.idCategoria,
          referencedTable: $db.categorieEserciziTable,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CategorieEserciziTableTableOrderingComposer(
                $db: $db,
                $table: $db.categorieEserciziTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$EserciziTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $EserciziTableTable> {
  $$EserciziTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get codice =>
      $composableBuilder(column: $table.codice, builder: (column) => column);

  GeneratedColumn<String> get nome =>
      $composableBuilder(column: $table.nome, builder: (column) => column);

  GeneratedColumn<String> get descrizione => $composableBuilder(
    column: $table.descrizione,
    builder: (column) => column,
  );

  GeneratedColumn<String> get istruzioni => $composableBuilder(
    column: $table.istruzioni,
    builder: (column) => column,
  );

  GeneratedColumn<String> get istruzioniRespirazione => $composableBuilder(
    column: $table.istruzioniRespirazione,
    builder: (column) => column,
  );

  GeneratedColumn<String> get noteSicurezza => $composableBuilder(
    column: $table.noteSicurezza,
    builder: (column) => column,
  );

  GeneratedColumn<String> get erroriComuni => $composableBuilder(
    column: $table.erroriComuni,
    builder: (column) => column,
  );

  GeneratedColumn<int> get livelloMinimo => $composableBuilder(
    column: $table.livelloMinimo,
    builder: (column) => column,
  );

  GeneratedColumn<int> get livelloMassimo => $composableBuilder(
    column: $table.livelloMassimo,
    builder: (column) => column,
  );

  GeneratedColumn<String> get livelloImpatto => $composableBuilder(
    column: $table.livelloImpatto,
    builder: (column) => column,
  );

  GeneratedColumn<String> get intensitaCardio => $composableBuilder(
    column: $table.intensitaCardio,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get richiedeEquilibrio => $composableBuilder(
    column: $table.richiedeEquilibrio,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get richiedePavimento => $composableBuilder(
    column: $table.richiedePavimento,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get richiedePosizioneEretta => $composableBuilder(
    column: $table.richiedePosizioneEretta,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get supportoConsentito => $composableBuilder(
    column: $table.supportoConsentito,
    builder: (column) => column,
  );

  GeneratedColumn<int> get seriePredefinite => $composableBuilder(
    column: $table.seriePredefinite,
    builder: (column) => column,
  );

  GeneratedColumn<int> get ripetizioniPredefinite => $composableBuilder(
    column: $table.ripetizioniPredefinite,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durataPredefinitaSecondi => $composableBuilder(
    column: $table.durataPredefinitaSecondi,
    builder: (column) => column,
  );

  GeneratedColumn<int> get recuperoPredefinitoSecondi => $composableBuilder(
    column: $table.recuperoPredefinitoSecondi,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get esercizioSistema => $composableBuilder(
    column: $table.esercizioSistema,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get attivo =>
      $composableBuilder(column: $table.attivo, builder: (column) => column);

  GeneratedColumn<int> get versioneCatalogo => $composableBuilder(
    column: $table.versioneCatalogo,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dataCreazione => $composableBuilder(
    column: $table.dataCreazione,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dataModifica => $composableBuilder(
    column: $table.dataModifica,
    builder: (column) => column,
  );

  $$CategorieEserciziTableTableAnnotationComposer get idCategoria {
    final $$CategorieEserciziTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.idCategoria,
          referencedTable: $db.categorieEserciziTable,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CategorieEserciziTableTableAnnotationComposer(
                $db: $db,
                $table: $db.categorieEserciziTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  Expression<T> eserciziGruppiMuscolariTableRefs<T extends Object>(
    Expression<T> Function(
      $$EserciziGruppiMuscolariTableTableAnnotationComposer a,
    )
    f,
  ) {
    final $$EserciziGruppiMuscolariTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.eserciziGruppiMuscolariTable,
          getReferencedColumn: (t) => t.idEsercizio,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$EserciziGruppiMuscolariTableTableAnnotationComposer(
                $db: $db,
                $table: $db.eserciziGruppiMuscolariTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> attrezzatureEserciziTableRefs<T extends Object>(
    Expression<T> Function($$AttrezzatureEserciziTableTableAnnotationComposer a)
    f,
  ) {
    final $$AttrezzatureEserciziTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.attrezzatureEserciziTable,
          getReferencedColumn: (t) => t.idEsercizio,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$AttrezzatureEserciziTableTableAnnotationComposer(
                $db: $db,
                $table: $db.attrezzatureEserciziTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> immaginiEserciziTableRefs<T extends Object>(
    Expression<T> Function($$ImmaginiEserciziTableTableAnnotationComposer a) f,
  ) {
    final $$ImmaginiEserciziTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.immaginiEserciziTable,
          getReferencedColumn: (t) => t.idEsercizio,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ImmaginiEserciziTableTableAnnotationComposer(
                $db: $db,
                $table: $db.immaginiEserciziTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> progressioniComePrecedente<T extends Object>(
    Expression<T> Function($$ProgressioniEserciziTableTableAnnotationComposer a)
    f,
  ) {
    final $$ProgressioniEserciziTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.progressioniEserciziTable,
          getReferencedColumn: (t) => t.idEsercizio,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ProgressioniEserciziTableTableAnnotationComposer(
                $db: $db,
                $table: $db.progressioniEserciziTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> progressioniComeSuccessivo<T extends Object>(
    Expression<T> Function($$ProgressioniEserciziTableTableAnnotationComposer a)
    f,
  ) {
    final $$ProgressioniEserciziTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.progressioniEserciziTable,
          getReferencedColumn: (t) => t.idEsercizioSuccessivo,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ProgressioniEserciziTableTableAnnotationComposer(
                $db: $db,
                $table: $db.progressioniEserciziTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> alternativeComeOriginale<T extends Object>(
    Expression<T> Function($$AlternativeEserciziTableTableAnnotationComposer a)
    f,
  ) {
    final $$AlternativeEserciziTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.alternativeEserciziTable,
          getReferencedColumn: (t) => t.idEsercizio,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$AlternativeEserciziTableTableAnnotationComposer(
                $db: $db,
                $table: $db.alternativeEserciziTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> alternativeComeAlternativa<T extends Object>(
    Expression<T> Function($$AlternativeEserciziTableTableAnnotationComposer a)
    f,
  ) {
    final $$AlternativeEserciziTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.alternativeEserciziTable,
          getReferencedColumn: (t) => t.idEsercizioAlternativo,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$AlternativeEserciziTableTableAnnotationComposer(
                $db: $db,
                $table: $db.alternativeEserciziTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$EserciziTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EserciziTableTable,
          EserciziTableData,
          $$EserciziTableTableFilterComposer,
          $$EserciziTableTableOrderingComposer,
          $$EserciziTableTableAnnotationComposer,
          $$EserciziTableTableCreateCompanionBuilder,
          $$EserciziTableTableUpdateCompanionBuilder,
          (EserciziTableData, $$EserciziTableTableReferences),
          EserciziTableData,
          PrefetchHooks Function({
            bool idCategoria,
            bool eserciziGruppiMuscolariTableRefs,
            bool attrezzatureEserciziTableRefs,
            bool immaginiEserciziTableRefs,
            bool progressioniComePrecedente,
            bool progressioniComeSuccessivo,
            bool alternativeComeOriginale,
            bool alternativeComeAlternativa,
          })
        > {
  $$EserciziTableTableTableManager(_$AppDatabase db, $EserciziTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EserciziTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EserciziTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EserciziTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> codice = const Value.absent(),
                Value<String> nome = const Value.absent(),
                Value<String> descrizione = const Value.absent(),
                Value<String> istruzioni = const Value.absent(),
                Value<String?> istruzioniRespirazione = const Value.absent(),
                Value<String?> noteSicurezza = const Value.absent(),
                Value<String?> erroriComuni = const Value.absent(),
                Value<int> idCategoria = const Value.absent(),
                Value<int> livelloMinimo = const Value.absent(),
                Value<int?> livelloMassimo = const Value.absent(),
                Value<String> livelloImpatto = const Value.absent(),
                Value<String?> intensitaCardio = const Value.absent(),
                Value<bool> richiedeEquilibrio = const Value.absent(),
                Value<bool> richiedePavimento = const Value.absent(),
                Value<bool> richiedePosizioneEretta = const Value.absent(),
                Value<bool> supportoConsentito = const Value.absent(),
                Value<int?> seriePredefinite = const Value.absent(),
                Value<int?> ripetizioniPredefinite = const Value.absent(),
                Value<int?> durataPredefinitaSecondi = const Value.absent(),
                Value<int?> recuperoPredefinitoSecondi = const Value.absent(),
                Value<bool> esercizioSistema = const Value.absent(),
                Value<bool> attivo = const Value.absent(),
                Value<int> versioneCatalogo = const Value.absent(),
                Value<DateTime> dataCreazione = const Value.absent(),
                Value<DateTime> dataModifica = const Value.absent(),
              }) => EserciziTableCompanion(
                id: id,
                codice: codice,
                nome: nome,
                descrizione: descrizione,
                istruzioni: istruzioni,
                istruzioniRespirazione: istruzioniRespirazione,
                noteSicurezza: noteSicurezza,
                erroriComuni: erroriComuni,
                idCategoria: idCategoria,
                livelloMinimo: livelloMinimo,
                livelloMassimo: livelloMassimo,
                livelloImpatto: livelloImpatto,
                intensitaCardio: intensitaCardio,
                richiedeEquilibrio: richiedeEquilibrio,
                richiedePavimento: richiedePavimento,
                richiedePosizioneEretta: richiedePosizioneEretta,
                supportoConsentito: supportoConsentito,
                seriePredefinite: seriePredefinite,
                ripetizioniPredefinite: ripetizioniPredefinite,
                durataPredefinitaSecondi: durataPredefinitaSecondi,
                recuperoPredefinitoSecondi: recuperoPredefinitoSecondi,
                esercizioSistema: esercizioSistema,
                attivo: attivo,
                versioneCatalogo: versioneCatalogo,
                dataCreazione: dataCreazione,
                dataModifica: dataModifica,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String codice,
                required String nome,
                required String descrizione,
                required String istruzioni,
                Value<String?> istruzioniRespirazione = const Value.absent(),
                Value<String?> noteSicurezza = const Value.absent(),
                Value<String?> erroriComuni = const Value.absent(),
                required int idCategoria,
                required int livelloMinimo,
                Value<int?> livelloMassimo = const Value.absent(),
                required String livelloImpatto,
                Value<String?> intensitaCardio = const Value.absent(),
                Value<bool> richiedeEquilibrio = const Value.absent(),
                Value<bool> richiedePavimento = const Value.absent(),
                Value<bool> richiedePosizioneEretta = const Value.absent(),
                Value<bool> supportoConsentito = const Value.absent(),
                Value<int?> seriePredefinite = const Value.absent(),
                Value<int?> ripetizioniPredefinite = const Value.absent(),
                Value<int?> durataPredefinitaSecondi = const Value.absent(),
                Value<int?> recuperoPredefinitoSecondi = const Value.absent(),
                Value<bool> esercizioSistema = const Value.absent(),
                Value<bool> attivo = const Value.absent(),
                required int versioneCatalogo,
                required DateTime dataCreazione,
                required DateTime dataModifica,
              }) => EserciziTableCompanion.insert(
                id: id,
                codice: codice,
                nome: nome,
                descrizione: descrizione,
                istruzioni: istruzioni,
                istruzioniRespirazione: istruzioniRespirazione,
                noteSicurezza: noteSicurezza,
                erroriComuni: erroriComuni,
                idCategoria: idCategoria,
                livelloMinimo: livelloMinimo,
                livelloMassimo: livelloMassimo,
                livelloImpatto: livelloImpatto,
                intensitaCardio: intensitaCardio,
                richiedeEquilibrio: richiedeEquilibrio,
                richiedePavimento: richiedePavimento,
                richiedePosizioneEretta: richiedePosizioneEretta,
                supportoConsentito: supportoConsentito,
                seriePredefinite: seriePredefinite,
                ripetizioniPredefinite: ripetizioniPredefinite,
                durataPredefinitaSecondi: durataPredefinitaSecondi,
                recuperoPredefinitoSecondi: recuperoPredefinitoSecondi,
                esercizioSistema: esercizioSistema,
                attivo: attivo,
                versioneCatalogo: versioneCatalogo,
                dataCreazione: dataCreazione,
                dataModifica: dataModifica,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$EserciziTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                idCategoria = false,
                eserciziGruppiMuscolariTableRefs = false,
                attrezzatureEserciziTableRefs = false,
                immaginiEserciziTableRefs = false,
                progressioniComePrecedente = false,
                progressioniComeSuccessivo = false,
                alternativeComeOriginale = false,
                alternativeComeAlternativa = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (eserciziGruppiMuscolariTableRefs)
                      db.eserciziGruppiMuscolariTable,
                    if (attrezzatureEserciziTableRefs)
                      db.attrezzatureEserciziTable,
                    if (immaginiEserciziTableRefs) db.immaginiEserciziTable,
                    if (progressioniComePrecedente)
                      db.progressioniEserciziTable,
                    if (progressioniComeSuccessivo)
                      db.progressioniEserciziTable,
                    if (alternativeComeOriginale) db.alternativeEserciziTable,
                    if (alternativeComeAlternativa) db.alternativeEserciziTable,
                  ],
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
                        if (idCategoria) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.idCategoria,
                                    referencedTable:
                                        $$EserciziTableTableReferences
                                            ._idCategoriaTable(db),
                                    referencedColumn:
                                        $$EserciziTableTableReferences
                                            ._idCategoriaTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (eserciziGruppiMuscolariTableRefs)
                        await $_getPrefetchedData<
                          EserciziTableData,
                          $EserciziTableTable,
                          EserciziGruppiMuscolariTableData
                        >(
                          currentTable: table,
                          referencedTable: $$EserciziTableTableReferences
                              ._eserciziGruppiMuscolariTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$EserciziTableTableReferences(
                                db,
                                table,
                                p0,
                              ).eserciziGruppiMuscolariTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.idEsercizio == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (attrezzatureEserciziTableRefs)
                        await $_getPrefetchedData<
                          EserciziTableData,
                          $EserciziTableTable,
                          AttrezzatureEserciziTableData
                        >(
                          currentTable: table,
                          referencedTable: $$EserciziTableTableReferences
                              ._attrezzatureEserciziTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$EserciziTableTableReferences(
                                db,
                                table,
                                p0,
                              ).attrezzatureEserciziTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.idEsercizio == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (immaginiEserciziTableRefs)
                        await $_getPrefetchedData<
                          EserciziTableData,
                          $EserciziTableTable,
                          ImmaginiEserciziTableData
                        >(
                          currentTable: table,
                          referencedTable: $$EserciziTableTableReferences
                              ._immaginiEserciziTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$EserciziTableTableReferences(
                                db,
                                table,
                                p0,
                              ).immaginiEserciziTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.idEsercizio == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (progressioniComePrecedente)
                        await $_getPrefetchedData<
                          EserciziTableData,
                          $EserciziTableTable,
                          ProgressioniEserciziTableData
                        >(
                          currentTable: table,
                          referencedTable: $$EserciziTableTableReferences
                              ._progressioniComePrecedenteTable(db),
                          managerFromTypedResult: (p0) =>
                              $$EserciziTableTableReferences(
                                db,
                                table,
                                p0,
                              ).progressioniComePrecedente,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.idEsercizio == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (progressioniComeSuccessivo)
                        await $_getPrefetchedData<
                          EserciziTableData,
                          $EserciziTableTable,
                          ProgressioniEserciziTableData
                        >(
                          currentTable: table,
                          referencedTable: $$EserciziTableTableReferences
                              ._progressioniComeSuccessivoTable(db),
                          managerFromTypedResult: (p0) =>
                              $$EserciziTableTableReferences(
                                db,
                                table,
                                p0,
                              ).progressioniComeSuccessivo,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.idEsercizioSuccessivo == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (alternativeComeOriginale)
                        await $_getPrefetchedData<
                          EserciziTableData,
                          $EserciziTableTable,
                          AlternativeEserciziTableData
                        >(
                          currentTable: table,
                          referencedTable: $$EserciziTableTableReferences
                              ._alternativeComeOriginaleTable(db),
                          managerFromTypedResult: (p0) =>
                              $$EserciziTableTableReferences(
                                db,
                                table,
                                p0,
                              ).alternativeComeOriginale,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.idEsercizio == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (alternativeComeAlternativa)
                        await $_getPrefetchedData<
                          EserciziTableData,
                          $EserciziTableTable,
                          AlternativeEserciziTableData
                        >(
                          currentTable: table,
                          referencedTable: $$EserciziTableTableReferences
                              ._alternativeComeAlternativaTable(db),
                          managerFromTypedResult: (p0) =>
                              $$EserciziTableTableReferences(
                                db,
                                table,
                                p0,
                              ).alternativeComeAlternativa,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.idEsercizioAlternativo == item.id,
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

typedef $$EserciziTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EserciziTableTable,
      EserciziTableData,
      $$EserciziTableTableFilterComposer,
      $$EserciziTableTableOrderingComposer,
      $$EserciziTableTableAnnotationComposer,
      $$EserciziTableTableCreateCompanionBuilder,
      $$EserciziTableTableUpdateCompanionBuilder,
      (EserciziTableData, $$EserciziTableTableReferences),
      EserciziTableData,
      PrefetchHooks Function({
        bool idCategoria,
        bool eserciziGruppiMuscolariTableRefs,
        bool attrezzatureEserciziTableRefs,
        bool immaginiEserciziTableRefs,
        bool progressioniComePrecedente,
        bool progressioniComeSuccessivo,
        bool alternativeComeOriginale,
        bool alternativeComeAlternativa,
      })
    >;
typedef $$EserciziGruppiMuscolariTableTableCreateCompanionBuilder =
    EserciziGruppiMuscolariTableCompanion Function({
      Value<int> id,
      required int idEsercizio,
      required int idGruppoMuscolare,
      required String tipoCoinvolgimento,
    });
typedef $$EserciziGruppiMuscolariTableTableUpdateCompanionBuilder =
    EserciziGruppiMuscolariTableCompanion Function({
      Value<int> id,
      Value<int> idEsercizio,
      Value<int> idGruppoMuscolare,
      Value<String> tipoCoinvolgimento,
    });

final class $$EserciziGruppiMuscolariTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $EserciziGruppiMuscolariTableTable,
          EserciziGruppiMuscolariTableData
        > {
  $$EserciziGruppiMuscolariTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $EserciziTableTable _idEsercizioTable(_$AppDatabase db) => db
      .eserciziTable
      .createAlias('esercizi_gruppi_muscolari__id_esercizio__esercizi__id');

  $$EserciziTableTableProcessedTableManager get idEsercizio {
    final $_column = $_itemColumn<int>('id_esercizio')!;

    final manager = $$EserciziTableTableTableManager(
      $_db,
      $_db.eserciziTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_idEsercizioTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $GruppiMuscolariTableTable _idGruppoMuscolareTable(_$AppDatabase db) =>
      db.gruppiMuscolariTable.createAlias(
        'esercizi_gruppi_muscolari__id_gruppo_muscolare__gruppi_muscolari__id',
      );

  $$GruppiMuscolariTableTableProcessedTableManager get idGruppoMuscolare {
    final $_column = $_itemColumn<int>('id_gruppo_muscolare')!;

    final manager = $$GruppiMuscolariTableTableTableManager(
      $_db,
      $_db.gruppiMuscolariTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_idGruppoMuscolareTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$EserciziGruppiMuscolariTableTableFilterComposer
    extends Composer<_$AppDatabase, $EserciziGruppiMuscolariTableTable> {
  $$EserciziGruppiMuscolariTableTableFilterComposer({
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

  ColumnFilters<String> get tipoCoinvolgimento => $composableBuilder(
    column: $table.tipoCoinvolgimento,
    builder: (column) => ColumnFilters(column),
  );

  $$EserciziTableTableFilterComposer get idEsercizio {
    final $$EserciziTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.idEsercizio,
      referencedTable: $db.eserciziTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EserciziTableTableFilterComposer(
            $db: $db,
            $table: $db.eserciziTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GruppiMuscolariTableTableFilterComposer get idGruppoMuscolare {
    final $$GruppiMuscolariTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.idGruppoMuscolare,
      referencedTable: $db.gruppiMuscolariTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GruppiMuscolariTableTableFilterComposer(
            $db: $db,
            $table: $db.gruppiMuscolariTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EserciziGruppiMuscolariTableTableOrderingComposer
    extends Composer<_$AppDatabase, $EserciziGruppiMuscolariTableTable> {
  $$EserciziGruppiMuscolariTableTableOrderingComposer({
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

  ColumnOrderings<String> get tipoCoinvolgimento => $composableBuilder(
    column: $table.tipoCoinvolgimento,
    builder: (column) => ColumnOrderings(column),
  );

  $$EserciziTableTableOrderingComposer get idEsercizio {
    final $$EserciziTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.idEsercizio,
      referencedTable: $db.eserciziTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EserciziTableTableOrderingComposer(
            $db: $db,
            $table: $db.eserciziTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GruppiMuscolariTableTableOrderingComposer get idGruppoMuscolare {
    final $$GruppiMuscolariTableTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.idGruppoMuscolare,
          referencedTable: $db.gruppiMuscolariTable,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$GruppiMuscolariTableTableOrderingComposer(
                $db: $db,
                $table: $db.gruppiMuscolariTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$EserciziGruppiMuscolariTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $EserciziGruppiMuscolariTableTable> {
  $$EserciziGruppiMuscolariTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tipoCoinvolgimento => $composableBuilder(
    column: $table.tipoCoinvolgimento,
    builder: (column) => column,
  );

  $$EserciziTableTableAnnotationComposer get idEsercizio {
    final $$EserciziTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.idEsercizio,
      referencedTable: $db.eserciziTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EserciziTableTableAnnotationComposer(
            $db: $db,
            $table: $db.eserciziTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GruppiMuscolariTableTableAnnotationComposer get idGruppoMuscolare {
    final $$GruppiMuscolariTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.idGruppoMuscolare,
          referencedTable: $db.gruppiMuscolariTable,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$GruppiMuscolariTableTableAnnotationComposer(
                $db: $db,
                $table: $db.gruppiMuscolariTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$EserciziGruppiMuscolariTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EserciziGruppiMuscolariTableTable,
          EserciziGruppiMuscolariTableData,
          $$EserciziGruppiMuscolariTableTableFilterComposer,
          $$EserciziGruppiMuscolariTableTableOrderingComposer,
          $$EserciziGruppiMuscolariTableTableAnnotationComposer,
          $$EserciziGruppiMuscolariTableTableCreateCompanionBuilder,
          $$EserciziGruppiMuscolariTableTableUpdateCompanionBuilder,
          (
            EserciziGruppiMuscolariTableData,
            $$EserciziGruppiMuscolariTableTableReferences,
          ),
          EserciziGruppiMuscolariTableData,
          PrefetchHooks Function({bool idEsercizio, bool idGruppoMuscolare})
        > {
  $$EserciziGruppiMuscolariTableTableTableManager(
    _$AppDatabase db,
    $EserciziGruppiMuscolariTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EserciziGruppiMuscolariTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$EserciziGruppiMuscolariTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$EserciziGruppiMuscolariTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> idEsercizio = const Value.absent(),
                Value<int> idGruppoMuscolare = const Value.absent(),
                Value<String> tipoCoinvolgimento = const Value.absent(),
              }) => EserciziGruppiMuscolariTableCompanion(
                id: id,
                idEsercizio: idEsercizio,
                idGruppoMuscolare: idGruppoMuscolare,
                tipoCoinvolgimento: tipoCoinvolgimento,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int idEsercizio,
                required int idGruppoMuscolare,
                required String tipoCoinvolgimento,
              }) => EserciziGruppiMuscolariTableCompanion.insert(
                id: id,
                idEsercizio: idEsercizio,
                idGruppoMuscolare: idGruppoMuscolare,
                tipoCoinvolgimento: tipoCoinvolgimento,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$EserciziGruppiMuscolariTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({idEsercizio = false, idGruppoMuscolare = false}) {
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
                    if (idEsercizio) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.idEsercizio,
                                referencedTable:
                                    $$EserciziGruppiMuscolariTableTableReferences
                                        ._idEsercizioTable(db),
                                referencedColumn:
                                    $$EserciziGruppiMuscolariTableTableReferences
                                        ._idEsercizioTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (idGruppoMuscolare) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.idGruppoMuscolare,
                                referencedTable:
                                    $$EserciziGruppiMuscolariTableTableReferences
                                        ._idGruppoMuscolareTable(db),
                                referencedColumn:
                                    $$EserciziGruppiMuscolariTableTableReferences
                                        ._idGruppoMuscolareTable(db)
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

typedef $$EserciziGruppiMuscolariTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EserciziGruppiMuscolariTableTable,
      EserciziGruppiMuscolariTableData,
      $$EserciziGruppiMuscolariTableTableFilterComposer,
      $$EserciziGruppiMuscolariTableTableOrderingComposer,
      $$EserciziGruppiMuscolariTableTableAnnotationComposer,
      $$EserciziGruppiMuscolariTableTableCreateCompanionBuilder,
      $$EserciziGruppiMuscolariTableTableUpdateCompanionBuilder,
      (
        EserciziGruppiMuscolariTableData,
        $$EserciziGruppiMuscolariTableTableReferences,
      ),
      EserciziGruppiMuscolariTableData,
      PrefetchHooks Function({bool idEsercizio, bool idGruppoMuscolare})
    >;
typedef $$AttrezzatureTableTableCreateCompanionBuilder =
    AttrezzatureTableCompanion Function({
      Value<int> id,
      required String codice,
      required String nome,
      Value<String?> descrizione,
      Value<String?> categoria,
      Value<double?> prezzoMinimoIndicativo,
      Value<double?> prezzoMassimoIndicativo,
      Value<int> priorita,
      Value<String?> queryRicerca,
      Value<bool> attiva,
      required int versioneCatalogo,
      required DateTime dataCreazione,
      required DateTime dataModifica,
    });
typedef $$AttrezzatureTableTableUpdateCompanionBuilder =
    AttrezzatureTableCompanion Function({
      Value<int> id,
      Value<String> codice,
      Value<String> nome,
      Value<String?> descrizione,
      Value<String?> categoria,
      Value<double?> prezzoMinimoIndicativo,
      Value<double?> prezzoMassimoIndicativo,
      Value<int> priorita,
      Value<String?> queryRicerca,
      Value<bool> attiva,
      Value<int> versioneCatalogo,
      Value<DateTime> dataCreazione,
      Value<DateTime> dataModifica,
    });

final class $$AttrezzatureTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $AttrezzatureTableTable,
          AttrezzatureTableData
        > {
  $$AttrezzatureTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<
    $AttrezzatureEserciziTableTable,
    List<AttrezzatureEserciziTableData>
  >
  _attrezzatureEserciziTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.attrezzatureEserciziTable,
        aliasName: 'attrezzature__id__attrezzature_esercizi__id_attrezzatura',
      );

  $$AttrezzatureEserciziTableTableProcessedTableManager
  get attrezzatureEserciziTableRefs {
    final manager = $$AttrezzatureEserciziTableTableTableManager(
      $_db,
      $_db.attrezzatureEserciziTable,
    ).filter((f) => f.idAttrezzatura.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _attrezzatureEserciziTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AttrezzatureTableTableFilterComposer
    extends Composer<_$AppDatabase, $AttrezzatureTableTable> {
  $$AttrezzatureTableTableFilterComposer({
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

  ColumnFilters<String> get codice => $composableBuilder(
    column: $table.codice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get descrizione => $composableBuilder(
    column: $table.descrizione,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoria => $composableBuilder(
    column: $table.categoria,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get prezzoMinimoIndicativo => $composableBuilder(
    column: $table.prezzoMinimoIndicativo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get prezzoMassimoIndicativo => $composableBuilder(
    column: $table.prezzoMassimoIndicativo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get priorita => $composableBuilder(
    column: $table.priorita,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get queryRicerca => $composableBuilder(
    column: $table.queryRicerca,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get attiva => $composableBuilder(
    column: $table.attiva,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get versioneCatalogo => $composableBuilder(
    column: $table.versioneCatalogo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dataCreazione => $composableBuilder(
    column: $table.dataCreazione,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dataModifica => $composableBuilder(
    column: $table.dataModifica,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> attrezzatureEserciziTableRefs(
    Expression<bool> Function($$AttrezzatureEserciziTableTableFilterComposer f)
    f,
  ) {
    final $$AttrezzatureEserciziTableTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.attrezzatureEserciziTable,
          getReferencedColumn: (t) => t.idAttrezzatura,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$AttrezzatureEserciziTableTableFilterComposer(
                $db: $db,
                $table: $db.attrezzatureEserciziTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$AttrezzatureTableTableOrderingComposer
    extends Composer<_$AppDatabase, $AttrezzatureTableTable> {
  $$AttrezzatureTableTableOrderingComposer({
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

  ColumnOrderings<String> get codice => $composableBuilder(
    column: $table.codice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get descrizione => $composableBuilder(
    column: $table.descrizione,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoria => $composableBuilder(
    column: $table.categoria,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get prezzoMinimoIndicativo => $composableBuilder(
    column: $table.prezzoMinimoIndicativo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get prezzoMassimoIndicativo => $composableBuilder(
    column: $table.prezzoMassimoIndicativo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priorita => $composableBuilder(
    column: $table.priorita,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get queryRicerca => $composableBuilder(
    column: $table.queryRicerca,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get attiva => $composableBuilder(
    column: $table.attiva,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get versioneCatalogo => $composableBuilder(
    column: $table.versioneCatalogo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dataCreazione => $composableBuilder(
    column: $table.dataCreazione,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dataModifica => $composableBuilder(
    column: $table.dataModifica,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AttrezzatureTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $AttrezzatureTableTable> {
  $$AttrezzatureTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get codice =>
      $composableBuilder(column: $table.codice, builder: (column) => column);

  GeneratedColumn<String> get nome =>
      $composableBuilder(column: $table.nome, builder: (column) => column);

  GeneratedColumn<String> get descrizione => $composableBuilder(
    column: $table.descrizione,
    builder: (column) => column,
  );

  GeneratedColumn<String> get categoria =>
      $composableBuilder(column: $table.categoria, builder: (column) => column);

  GeneratedColumn<double> get prezzoMinimoIndicativo => $composableBuilder(
    column: $table.prezzoMinimoIndicativo,
    builder: (column) => column,
  );

  GeneratedColumn<double> get prezzoMassimoIndicativo => $composableBuilder(
    column: $table.prezzoMassimoIndicativo,
    builder: (column) => column,
  );

  GeneratedColumn<int> get priorita =>
      $composableBuilder(column: $table.priorita, builder: (column) => column);

  GeneratedColumn<String> get queryRicerca => $composableBuilder(
    column: $table.queryRicerca,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get attiva =>
      $composableBuilder(column: $table.attiva, builder: (column) => column);

  GeneratedColumn<int> get versioneCatalogo => $composableBuilder(
    column: $table.versioneCatalogo,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dataCreazione => $composableBuilder(
    column: $table.dataCreazione,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dataModifica => $composableBuilder(
    column: $table.dataModifica,
    builder: (column) => column,
  );

  Expression<T> attrezzatureEserciziTableRefs<T extends Object>(
    Expression<T> Function($$AttrezzatureEserciziTableTableAnnotationComposer a)
    f,
  ) {
    final $$AttrezzatureEserciziTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.attrezzatureEserciziTable,
          getReferencedColumn: (t) => t.idAttrezzatura,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$AttrezzatureEserciziTableTableAnnotationComposer(
                $db: $db,
                $table: $db.attrezzatureEserciziTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$AttrezzatureTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AttrezzatureTableTable,
          AttrezzatureTableData,
          $$AttrezzatureTableTableFilterComposer,
          $$AttrezzatureTableTableOrderingComposer,
          $$AttrezzatureTableTableAnnotationComposer,
          $$AttrezzatureTableTableCreateCompanionBuilder,
          $$AttrezzatureTableTableUpdateCompanionBuilder,
          (AttrezzatureTableData, $$AttrezzatureTableTableReferences),
          AttrezzatureTableData,
          PrefetchHooks Function({bool attrezzatureEserciziTableRefs})
        > {
  $$AttrezzatureTableTableTableManager(
    _$AppDatabase db,
    $AttrezzatureTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AttrezzatureTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AttrezzatureTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AttrezzatureTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> codice = const Value.absent(),
                Value<String> nome = const Value.absent(),
                Value<String?> descrizione = const Value.absent(),
                Value<String?> categoria = const Value.absent(),
                Value<double?> prezzoMinimoIndicativo = const Value.absent(),
                Value<double?> prezzoMassimoIndicativo = const Value.absent(),
                Value<int> priorita = const Value.absent(),
                Value<String?> queryRicerca = const Value.absent(),
                Value<bool> attiva = const Value.absent(),
                Value<int> versioneCatalogo = const Value.absent(),
                Value<DateTime> dataCreazione = const Value.absent(),
                Value<DateTime> dataModifica = const Value.absent(),
              }) => AttrezzatureTableCompanion(
                id: id,
                codice: codice,
                nome: nome,
                descrizione: descrizione,
                categoria: categoria,
                prezzoMinimoIndicativo: prezzoMinimoIndicativo,
                prezzoMassimoIndicativo: prezzoMassimoIndicativo,
                priorita: priorita,
                queryRicerca: queryRicerca,
                attiva: attiva,
                versioneCatalogo: versioneCatalogo,
                dataCreazione: dataCreazione,
                dataModifica: dataModifica,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String codice,
                required String nome,
                Value<String?> descrizione = const Value.absent(),
                Value<String?> categoria = const Value.absent(),
                Value<double?> prezzoMinimoIndicativo = const Value.absent(),
                Value<double?> prezzoMassimoIndicativo = const Value.absent(),
                Value<int> priorita = const Value.absent(),
                Value<String?> queryRicerca = const Value.absent(),
                Value<bool> attiva = const Value.absent(),
                required int versioneCatalogo,
                required DateTime dataCreazione,
                required DateTime dataModifica,
              }) => AttrezzatureTableCompanion.insert(
                id: id,
                codice: codice,
                nome: nome,
                descrizione: descrizione,
                categoria: categoria,
                prezzoMinimoIndicativo: prezzoMinimoIndicativo,
                prezzoMassimoIndicativo: prezzoMassimoIndicativo,
                priorita: priorita,
                queryRicerca: queryRicerca,
                attiva: attiva,
                versioneCatalogo: versioneCatalogo,
                dataCreazione: dataCreazione,
                dataModifica: dataModifica,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AttrezzatureTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({attrezzatureEserciziTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (attrezzatureEserciziTableRefs) db.attrezzatureEserciziTable,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (attrezzatureEserciziTableRefs)
                    await $_getPrefetchedData<
                      AttrezzatureTableData,
                      $AttrezzatureTableTable,
                      AttrezzatureEserciziTableData
                    >(
                      currentTable: table,
                      referencedTable: $$AttrezzatureTableTableReferences
                          ._attrezzatureEserciziTableRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$AttrezzatureTableTableReferences(
                            db,
                            table,
                            p0,
                          ).attrezzatureEserciziTableRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.idAttrezzatura == item.id,
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

typedef $$AttrezzatureTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AttrezzatureTableTable,
      AttrezzatureTableData,
      $$AttrezzatureTableTableFilterComposer,
      $$AttrezzatureTableTableOrderingComposer,
      $$AttrezzatureTableTableAnnotationComposer,
      $$AttrezzatureTableTableCreateCompanionBuilder,
      $$AttrezzatureTableTableUpdateCompanionBuilder,
      (AttrezzatureTableData, $$AttrezzatureTableTableReferences),
      AttrezzatureTableData,
      PrefetchHooks Function({bool attrezzatureEserciziTableRefs})
    >;
typedef $$AttrezzatureEserciziTableTableCreateCompanionBuilder =
    AttrezzatureEserciziTableCompanion Function({
      Value<int> id,
      required int idEsercizio,
      required int idAttrezzatura,
      Value<bool> obbligatoria,
    });
typedef $$AttrezzatureEserciziTableTableUpdateCompanionBuilder =
    AttrezzatureEserciziTableCompanion Function({
      Value<int> id,
      Value<int> idEsercizio,
      Value<int> idAttrezzatura,
      Value<bool> obbligatoria,
    });

final class $$AttrezzatureEserciziTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $AttrezzatureEserciziTableTable,
          AttrezzatureEserciziTableData
        > {
  $$AttrezzatureEserciziTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $EserciziTableTable _idEsercizioTable(_$AppDatabase db) => db
      .eserciziTable
      .createAlias('attrezzature_esercizi__id_esercizio__esercizi__id');

  $$EserciziTableTableProcessedTableManager get idEsercizio {
    final $_column = $_itemColumn<int>('id_esercizio')!;

    final manager = $$EserciziTableTableTableManager(
      $_db,
      $_db.eserciziTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_idEsercizioTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $AttrezzatureTableTable _idAttrezzaturaTable(_$AppDatabase db) => db
      .attrezzatureTable
      .createAlias('attrezzature_esercizi__id_attrezzatura__attrezzature__id');

  $$AttrezzatureTableTableProcessedTableManager get idAttrezzatura {
    final $_column = $_itemColumn<int>('id_attrezzatura')!;

    final manager = $$AttrezzatureTableTableTableManager(
      $_db,
      $_db.attrezzatureTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_idAttrezzaturaTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AttrezzatureEserciziTableTableFilterComposer
    extends Composer<_$AppDatabase, $AttrezzatureEserciziTableTable> {
  $$AttrezzatureEserciziTableTableFilterComposer({
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

  ColumnFilters<bool> get obbligatoria => $composableBuilder(
    column: $table.obbligatoria,
    builder: (column) => ColumnFilters(column),
  );

  $$EserciziTableTableFilterComposer get idEsercizio {
    final $$EserciziTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.idEsercizio,
      referencedTable: $db.eserciziTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EserciziTableTableFilterComposer(
            $db: $db,
            $table: $db.eserciziTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AttrezzatureTableTableFilterComposer get idAttrezzatura {
    final $$AttrezzatureTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.idAttrezzatura,
      referencedTable: $db.attrezzatureTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttrezzatureTableTableFilterComposer(
            $db: $db,
            $table: $db.attrezzatureTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AttrezzatureEserciziTableTableOrderingComposer
    extends Composer<_$AppDatabase, $AttrezzatureEserciziTableTable> {
  $$AttrezzatureEserciziTableTableOrderingComposer({
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

  ColumnOrderings<bool> get obbligatoria => $composableBuilder(
    column: $table.obbligatoria,
    builder: (column) => ColumnOrderings(column),
  );

  $$EserciziTableTableOrderingComposer get idEsercizio {
    final $$EserciziTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.idEsercizio,
      referencedTable: $db.eserciziTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EserciziTableTableOrderingComposer(
            $db: $db,
            $table: $db.eserciziTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AttrezzatureTableTableOrderingComposer get idAttrezzatura {
    final $$AttrezzatureTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.idAttrezzatura,
      referencedTable: $db.attrezzatureTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttrezzatureTableTableOrderingComposer(
            $db: $db,
            $table: $db.attrezzatureTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AttrezzatureEserciziTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $AttrezzatureEserciziTableTable> {
  $$AttrezzatureEserciziTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<bool> get obbligatoria => $composableBuilder(
    column: $table.obbligatoria,
    builder: (column) => column,
  );

  $$EserciziTableTableAnnotationComposer get idEsercizio {
    final $$EserciziTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.idEsercizio,
      referencedTable: $db.eserciziTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EserciziTableTableAnnotationComposer(
            $db: $db,
            $table: $db.eserciziTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AttrezzatureTableTableAnnotationComposer get idAttrezzatura {
    final $$AttrezzatureTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.idAttrezzatura,
          referencedTable: $db.attrezzatureTable,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$AttrezzatureTableTableAnnotationComposer(
                $db: $db,
                $table: $db.attrezzatureTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$AttrezzatureEserciziTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AttrezzatureEserciziTableTable,
          AttrezzatureEserciziTableData,
          $$AttrezzatureEserciziTableTableFilterComposer,
          $$AttrezzatureEserciziTableTableOrderingComposer,
          $$AttrezzatureEserciziTableTableAnnotationComposer,
          $$AttrezzatureEserciziTableTableCreateCompanionBuilder,
          $$AttrezzatureEserciziTableTableUpdateCompanionBuilder,
          (
            AttrezzatureEserciziTableData,
            $$AttrezzatureEserciziTableTableReferences,
          ),
          AttrezzatureEserciziTableData,
          PrefetchHooks Function({bool idEsercizio, bool idAttrezzatura})
        > {
  $$AttrezzatureEserciziTableTableTableManager(
    _$AppDatabase db,
    $AttrezzatureEserciziTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AttrezzatureEserciziTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$AttrezzatureEserciziTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$AttrezzatureEserciziTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> idEsercizio = const Value.absent(),
                Value<int> idAttrezzatura = const Value.absent(),
                Value<bool> obbligatoria = const Value.absent(),
              }) => AttrezzatureEserciziTableCompanion(
                id: id,
                idEsercizio: idEsercizio,
                idAttrezzatura: idAttrezzatura,
                obbligatoria: obbligatoria,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int idEsercizio,
                required int idAttrezzatura,
                Value<bool> obbligatoria = const Value.absent(),
              }) => AttrezzatureEserciziTableCompanion.insert(
                id: id,
                idEsercizio: idEsercizio,
                idAttrezzatura: idAttrezzatura,
                obbligatoria: obbligatoria,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AttrezzatureEserciziTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({idEsercizio = false, idAttrezzatura = false}) {
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
                    if (idEsercizio) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.idEsercizio,
                                referencedTable:
                                    $$AttrezzatureEserciziTableTableReferences
                                        ._idEsercizioTable(db),
                                referencedColumn:
                                    $$AttrezzatureEserciziTableTableReferences
                                        ._idEsercizioTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (idAttrezzatura) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.idAttrezzatura,
                                referencedTable:
                                    $$AttrezzatureEserciziTableTableReferences
                                        ._idAttrezzaturaTable(db),
                                referencedColumn:
                                    $$AttrezzatureEserciziTableTableReferences
                                        ._idAttrezzaturaTable(db)
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

typedef $$AttrezzatureEserciziTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AttrezzatureEserciziTableTable,
      AttrezzatureEserciziTableData,
      $$AttrezzatureEserciziTableTableFilterComposer,
      $$AttrezzatureEserciziTableTableOrderingComposer,
      $$AttrezzatureEserciziTableTableAnnotationComposer,
      $$AttrezzatureEserciziTableTableCreateCompanionBuilder,
      $$AttrezzatureEserciziTableTableUpdateCompanionBuilder,
      (
        AttrezzatureEserciziTableData,
        $$AttrezzatureEserciziTableTableReferences,
      ),
      AttrezzatureEserciziTableData,
      PrefetchHooks Function({bool idEsercizio, bool idAttrezzatura})
    >;
typedef $$ImmaginiEserciziTableTableCreateCompanionBuilder =
    ImmaginiEserciziTableCompanion Function({
      Value<int> id,
      required int idEsercizio,
      required String tipoSorgente,
      Value<String?> percorsoAsset,
      Value<String?> percorsoFileLocale,
      required String tipoImmagine,
      Value<String?> didascalia,
      Value<int> ordineVisualizzazione,
      Value<bool> attiva,
      required DateTime dataCreazione,
      required DateTime dataModifica,
    });
typedef $$ImmaginiEserciziTableTableUpdateCompanionBuilder =
    ImmaginiEserciziTableCompanion Function({
      Value<int> id,
      Value<int> idEsercizio,
      Value<String> tipoSorgente,
      Value<String?> percorsoAsset,
      Value<String?> percorsoFileLocale,
      Value<String> tipoImmagine,
      Value<String?> didascalia,
      Value<int> ordineVisualizzazione,
      Value<bool> attiva,
      Value<DateTime> dataCreazione,
      Value<DateTime> dataModifica,
    });

final class $$ImmaginiEserciziTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ImmaginiEserciziTableTable,
          ImmaginiEserciziTableData
        > {
  $$ImmaginiEserciziTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $EserciziTableTable _idEsercizioTable(_$AppDatabase db) => db
      .eserciziTable
      .createAlias('immagini_esercizi__id_esercizio__esercizi__id');

  $$EserciziTableTableProcessedTableManager get idEsercizio {
    final $_column = $_itemColumn<int>('id_esercizio')!;

    final manager = $$EserciziTableTableTableManager(
      $_db,
      $_db.eserciziTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_idEsercizioTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ImmaginiEserciziTableTableFilterComposer
    extends Composer<_$AppDatabase, $ImmaginiEserciziTableTable> {
  $$ImmaginiEserciziTableTableFilterComposer({
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

  ColumnFilters<String> get tipoSorgente => $composableBuilder(
    column: $table.tipoSorgente,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get percorsoAsset => $composableBuilder(
    column: $table.percorsoAsset,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get percorsoFileLocale => $composableBuilder(
    column: $table.percorsoFileLocale,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tipoImmagine => $composableBuilder(
    column: $table.tipoImmagine,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get didascalia => $composableBuilder(
    column: $table.didascalia,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ordineVisualizzazione => $composableBuilder(
    column: $table.ordineVisualizzazione,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get attiva => $composableBuilder(
    column: $table.attiva,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dataCreazione => $composableBuilder(
    column: $table.dataCreazione,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dataModifica => $composableBuilder(
    column: $table.dataModifica,
    builder: (column) => ColumnFilters(column),
  );

  $$EserciziTableTableFilterComposer get idEsercizio {
    final $$EserciziTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.idEsercizio,
      referencedTable: $db.eserciziTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EserciziTableTableFilterComposer(
            $db: $db,
            $table: $db.eserciziTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ImmaginiEserciziTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ImmaginiEserciziTableTable> {
  $$ImmaginiEserciziTableTableOrderingComposer({
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

  ColumnOrderings<String> get tipoSorgente => $composableBuilder(
    column: $table.tipoSorgente,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get percorsoAsset => $composableBuilder(
    column: $table.percorsoAsset,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get percorsoFileLocale => $composableBuilder(
    column: $table.percorsoFileLocale,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipoImmagine => $composableBuilder(
    column: $table.tipoImmagine,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get didascalia => $composableBuilder(
    column: $table.didascalia,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ordineVisualizzazione => $composableBuilder(
    column: $table.ordineVisualizzazione,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get attiva => $composableBuilder(
    column: $table.attiva,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dataCreazione => $composableBuilder(
    column: $table.dataCreazione,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dataModifica => $composableBuilder(
    column: $table.dataModifica,
    builder: (column) => ColumnOrderings(column),
  );

  $$EserciziTableTableOrderingComposer get idEsercizio {
    final $$EserciziTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.idEsercizio,
      referencedTable: $db.eserciziTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EserciziTableTableOrderingComposer(
            $db: $db,
            $table: $db.eserciziTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ImmaginiEserciziTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ImmaginiEserciziTableTable> {
  $$ImmaginiEserciziTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tipoSorgente => $composableBuilder(
    column: $table.tipoSorgente,
    builder: (column) => column,
  );

  GeneratedColumn<String> get percorsoAsset => $composableBuilder(
    column: $table.percorsoAsset,
    builder: (column) => column,
  );

  GeneratedColumn<String> get percorsoFileLocale => $composableBuilder(
    column: $table.percorsoFileLocale,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tipoImmagine => $composableBuilder(
    column: $table.tipoImmagine,
    builder: (column) => column,
  );

  GeneratedColumn<String> get didascalia => $composableBuilder(
    column: $table.didascalia,
    builder: (column) => column,
  );

  GeneratedColumn<int> get ordineVisualizzazione => $composableBuilder(
    column: $table.ordineVisualizzazione,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get attiva =>
      $composableBuilder(column: $table.attiva, builder: (column) => column);

  GeneratedColumn<DateTime> get dataCreazione => $composableBuilder(
    column: $table.dataCreazione,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dataModifica => $composableBuilder(
    column: $table.dataModifica,
    builder: (column) => column,
  );

  $$EserciziTableTableAnnotationComposer get idEsercizio {
    final $$EserciziTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.idEsercizio,
      referencedTable: $db.eserciziTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EserciziTableTableAnnotationComposer(
            $db: $db,
            $table: $db.eserciziTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ImmaginiEserciziTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ImmaginiEserciziTableTable,
          ImmaginiEserciziTableData,
          $$ImmaginiEserciziTableTableFilterComposer,
          $$ImmaginiEserciziTableTableOrderingComposer,
          $$ImmaginiEserciziTableTableAnnotationComposer,
          $$ImmaginiEserciziTableTableCreateCompanionBuilder,
          $$ImmaginiEserciziTableTableUpdateCompanionBuilder,
          (ImmaginiEserciziTableData, $$ImmaginiEserciziTableTableReferences),
          ImmaginiEserciziTableData,
          PrefetchHooks Function({bool idEsercizio})
        > {
  $$ImmaginiEserciziTableTableTableManager(
    _$AppDatabase db,
    $ImmaginiEserciziTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ImmaginiEserciziTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$ImmaginiEserciziTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ImmaginiEserciziTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> idEsercizio = const Value.absent(),
                Value<String> tipoSorgente = const Value.absent(),
                Value<String?> percorsoAsset = const Value.absent(),
                Value<String?> percorsoFileLocale = const Value.absent(),
                Value<String> tipoImmagine = const Value.absent(),
                Value<String?> didascalia = const Value.absent(),
                Value<int> ordineVisualizzazione = const Value.absent(),
                Value<bool> attiva = const Value.absent(),
                Value<DateTime> dataCreazione = const Value.absent(),
                Value<DateTime> dataModifica = const Value.absent(),
              }) => ImmaginiEserciziTableCompanion(
                id: id,
                idEsercizio: idEsercizio,
                tipoSorgente: tipoSorgente,
                percorsoAsset: percorsoAsset,
                percorsoFileLocale: percorsoFileLocale,
                tipoImmagine: tipoImmagine,
                didascalia: didascalia,
                ordineVisualizzazione: ordineVisualizzazione,
                attiva: attiva,
                dataCreazione: dataCreazione,
                dataModifica: dataModifica,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int idEsercizio,
                required String tipoSorgente,
                Value<String?> percorsoAsset = const Value.absent(),
                Value<String?> percorsoFileLocale = const Value.absent(),
                required String tipoImmagine,
                Value<String?> didascalia = const Value.absent(),
                Value<int> ordineVisualizzazione = const Value.absent(),
                Value<bool> attiva = const Value.absent(),
                required DateTime dataCreazione,
                required DateTime dataModifica,
              }) => ImmaginiEserciziTableCompanion.insert(
                id: id,
                idEsercizio: idEsercizio,
                tipoSorgente: tipoSorgente,
                percorsoAsset: percorsoAsset,
                percorsoFileLocale: percorsoFileLocale,
                tipoImmagine: tipoImmagine,
                didascalia: didascalia,
                ordineVisualizzazione: ordineVisualizzazione,
                attiva: attiva,
                dataCreazione: dataCreazione,
                dataModifica: dataModifica,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ImmaginiEserciziTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({idEsercizio = false}) {
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
                    if (idEsercizio) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.idEsercizio,
                                referencedTable:
                                    $$ImmaginiEserciziTableTableReferences
                                        ._idEsercizioTable(db),
                                referencedColumn:
                                    $$ImmaginiEserciziTableTableReferences
                                        ._idEsercizioTable(db)
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

typedef $$ImmaginiEserciziTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ImmaginiEserciziTableTable,
      ImmaginiEserciziTableData,
      $$ImmaginiEserciziTableTableFilterComposer,
      $$ImmaginiEserciziTableTableOrderingComposer,
      $$ImmaginiEserciziTableTableAnnotationComposer,
      $$ImmaginiEserciziTableTableCreateCompanionBuilder,
      $$ImmaginiEserciziTableTableUpdateCompanionBuilder,
      (ImmaginiEserciziTableData, $$ImmaginiEserciziTableTableReferences),
      ImmaginiEserciziTableData,
      PrefetchHooks Function({bool idEsercizio})
    >;
typedef $$ProgressioniEserciziTableTableCreateCompanionBuilder =
    ProgressioniEserciziTableCompanion Function({
      Value<int> id,
      required int idEsercizio,
      required int idEsercizioSuccessivo,
      required String tipoProgressione,
      required int livelloMinimo,
      Value<int> priorita,
      Value<String?> note,
      Value<bool> attiva,
      required DateTime dataCreazione,
      required DateTime dataModifica,
    });
typedef $$ProgressioniEserciziTableTableUpdateCompanionBuilder =
    ProgressioniEserciziTableCompanion Function({
      Value<int> id,
      Value<int> idEsercizio,
      Value<int> idEsercizioSuccessivo,
      Value<String> tipoProgressione,
      Value<int> livelloMinimo,
      Value<int> priorita,
      Value<String?> note,
      Value<bool> attiva,
      Value<DateTime> dataCreazione,
      Value<DateTime> dataModifica,
    });

final class $$ProgressioniEserciziTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ProgressioniEserciziTableTable,
          ProgressioniEserciziTableData
        > {
  $$ProgressioniEserciziTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $EserciziTableTable _idEsercizioTable(_$AppDatabase db) => db
      .eserciziTable
      .createAlias('progressioni_esercizi__id_esercizio__esercizi__id');

  $$EserciziTableTableProcessedTableManager get idEsercizio {
    final $_column = $_itemColumn<int>('id_esercizio')!;

    final manager = $$EserciziTableTableTableManager(
      $_db,
      $_db.eserciziTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_idEsercizioTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $EserciziTableTable _idEsercizioSuccessivoTable(_$AppDatabase db) =>
      db.eserciziTable.createAlias(
        'progressioni_esercizi__id_esercizio_successivo__esercizi__id',
      );

  $$EserciziTableTableProcessedTableManager get idEsercizioSuccessivo {
    final $_column = $_itemColumn<int>('id_esercizio_successivo')!;

    final manager = $$EserciziTableTableTableManager(
      $_db,
      $_db.eserciziTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(
      _idEsercizioSuccessivoTable($_db),
    );
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ProgressioniEserciziTableTableFilterComposer
    extends Composer<_$AppDatabase, $ProgressioniEserciziTableTable> {
  $$ProgressioniEserciziTableTableFilterComposer({
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

  ColumnFilters<String> get tipoProgressione => $composableBuilder(
    column: $table.tipoProgressione,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get livelloMinimo => $composableBuilder(
    column: $table.livelloMinimo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get priorita => $composableBuilder(
    column: $table.priorita,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get attiva => $composableBuilder(
    column: $table.attiva,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dataCreazione => $composableBuilder(
    column: $table.dataCreazione,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dataModifica => $composableBuilder(
    column: $table.dataModifica,
    builder: (column) => ColumnFilters(column),
  );

  $$EserciziTableTableFilterComposer get idEsercizio {
    final $$EserciziTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.idEsercizio,
      referencedTable: $db.eserciziTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EserciziTableTableFilterComposer(
            $db: $db,
            $table: $db.eserciziTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EserciziTableTableFilterComposer get idEsercizioSuccessivo {
    final $$EserciziTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.idEsercizioSuccessivo,
      referencedTable: $db.eserciziTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EserciziTableTableFilterComposer(
            $db: $db,
            $table: $db.eserciziTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProgressioniEserciziTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ProgressioniEserciziTableTable> {
  $$ProgressioniEserciziTableTableOrderingComposer({
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

  ColumnOrderings<String> get tipoProgressione => $composableBuilder(
    column: $table.tipoProgressione,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get livelloMinimo => $composableBuilder(
    column: $table.livelloMinimo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priorita => $composableBuilder(
    column: $table.priorita,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get attiva => $composableBuilder(
    column: $table.attiva,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dataCreazione => $composableBuilder(
    column: $table.dataCreazione,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dataModifica => $composableBuilder(
    column: $table.dataModifica,
    builder: (column) => ColumnOrderings(column),
  );

  $$EserciziTableTableOrderingComposer get idEsercizio {
    final $$EserciziTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.idEsercizio,
      referencedTable: $db.eserciziTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EserciziTableTableOrderingComposer(
            $db: $db,
            $table: $db.eserciziTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EserciziTableTableOrderingComposer get idEsercizioSuccessivo {
    final $$EserciziTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.idEsercizioSuccessivo,
      referencedTable: $db.eserciziTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EserciziTableTableOrderingComposer(
            $db: $db,
            $table: $db.eserciziTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProgressioniEserciziTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProgressioniEserciziTableTable> {
  $$ProgressioniEserciziTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tipoProgressione => $composableBuilder(
    column: $table.tipoProgressione,
    builder: (column) => column,
  );

  GeneratedColumn<int> get livelloMinimo => $composableBuilder(
    column: $table.livelloMinimo,
    builder: (column) => column,
  );

  GeneratedColumn<int> get priorita =>
      $composableBuilder(column: $table.priorita, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<bool> get attiva =>
      $composableBuilder(column: $table.attiva, builder: (column) => column);

  GeneratedColumn<DateTime> get dataCreazione => $composableBuilder(
    column: $table.dataCreazione,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dataModifica => $composableBuilder(
    column: $table.dataModifica,
    builder: (column) => column,
  );

  $$EserciziTableTableAnnotationComposer get idEsercizio {
    final $$EserciziTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.idEsercizio,
      referencedTable: $db.eserciziTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EserciziTableTableAnnotationComposer(
            $db: $db,
            $table: $db.eserciziTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EserciziTableTableAnnotationComposer get idEsercizioSuccessivo {
    final $$EserciziTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.idEsercizioSuccessivo,
      referencedTable: $db.eserciziTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EserciziTableTableAnnotationComposer(
            $db: $db,
            $table: $db.eserciziTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProgressioniEserciziTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProgressioniEserciziTableTable,
          ProgressioniEserciziTableData,
          $$ProgressioniEserciziTableTableFilterComposer,
          $$ProgressioniEserciziTableTableOrderingComposer,
          $$ProgressioniEserciziTableTableAnnotationComposer,
          $$ProgressioniEserciziTableTableCreateCompanionBuilder,
          $$ProgressioniEserciziTableTableUpdateCompanionBuilder,
          (
            ProgressioniEserciziTableData,
            $$ProgressioniEserciziTableTableReferences,
          ),
          ProgressioniEserciziTableData,
          PrefetchHooks Function({bool idEsercizio, bool idEsercizioSuccessivo})
        > {
  $$ProgressioniEserciziTableTableTableManager(
    _$AppDatabase db,
    $ProgressioniEserciziTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProgressioniEserciziTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$ProgressioniEserciziTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ProgressioniEserciziTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> idEsercizio = const Value.absent(),
                Value<int> idEsercizioSuccessivo = const Value.absent(),
                Value<String> tipoProgressione = const Value.absent(),
                Value<int> livelloMinimo = const Value.absent(),
                Value<int> priorita = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<bool> attiva = const Value.absent(),
                Value<DateTime> dataCreazione = const Value.absent(),
                Value<DateTime> dataModifica = const Value.absent(),
              }) => ProgressioniEserciziTableCompanion(
                id: id,
                idEsercizio: idEsercizio,
                idEsercizioSuccessivo: idEsercizioSuccessivo,
                tipoProgressione: tipoProgressione,
                livelloMinimo: livelloMinimo,
                priorita: priorita,
                note: note,
                attiva: attiva,
                dataCreazione: dataCreazione,
                dataModifica: dataModifica,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int idEsercizio,
                required int idEsercizioSuccessivo,
                required String tipoProgressione,
                required int livelloMinimo,
                Value<int> priorita = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<bool> attiva = const Value.absent(),
                required DateTime dataCreazione,
                required DateTime dataModifica,
              }) => ProgressioniEserciziTableCompanion.insert(
                id: id,
                idEsercizio: idEsercizio,
                idEsercizioSuccessivo: idEsercizioSuccessivo,
                tipoProgressione: tipoProgressione,
                livelloMinimo: livelloMinimo,
                priorita: priorita,
                note: note,
                attiva: attiva,
                dataCreazione: dataCreazione,
                dataModifica: dataModifica,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ProgressioniEserciziTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({idEsercizio = false, idEsercizioSuccessivo = false}) {
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
                        if (idEsercizio) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.idEsercizio,
                                    referencedTable:
                                        $$ProgressioniEserciziTableTableReferences
                                            ._idEsercizioTable(db),
                                    referencedColumn:
                                        $$ProgressioniEserciziTableTableReferences
                                            ._idEsercizioTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (idEsercizioSuccessivo) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.idEsercizioSuccessivo,
                                    referencedTable:
                                        $$ProgressioniEserciziTableTableReferences
                                            ._idEsercizioSuccessivoTable(db),
                                    referencedColumn:
                                        $$ProgressioniEserciziTableTableReferences
                                            ._idEsercizioSuccessivoTable(db)
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

typedef $$ProgressioniEserciziTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProgressioniEserciziTableTable,
      ProgressioniEserciziTableData,
      $$ProgressioniEserciziTableTableFilterComposer,
      $$ProgressioniEserciziTableTableOrderingComposer,
      $$ProgressioniEserciziTableTableAnnotationComposer,
      $$ProgressioniEserciziTableTableCreateCompanionBuilder,
      $$ProgressioniEserciziTableTableUpdateCompanionBuilder,
      (
        ProgressioniEserciziTableData,
        $$ProgressioniEserciziTableTableReferences,
      ),
      ProgressioniEserciziTableData,
      PrefetchHooks Function({bool idEsercizio, bool idEsercizioSuccessivo})
    >;
typedef $$AlternativeEserciziTableTableCreateCompanionBuilder =
    AlternativeEserciziTableCompanion Function({
      Value<int> id,
      required int idEsercizio,
      required int idEsercizioAlternativo,
      required String codiceMotivo,
      Value<int> priorita,
      Value<String?> note,
      Value<bool> attiva,
      required DateTime dataCreazione,
      required DateTime dataModifica,
    });
typedef $$AlternativeEserciziTableTableUpdateCompanionBuilder =
    AlternativeEserciziTableCompanion Function({
      Value<int> id,
      Value<int> idEsercizio,
      Value<int> idEsercizioAlternativo,
      Value<String> codiceMotivo,
      Value<int> priorita,
      Value<String?> note,
      Value<bool> attiva,
      Value<DateTime> dataCreazione,
      Value<DateTime> dataModifica,
    });

final class $$AlternativeEserciziTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $AlternativeEserciziTableTable,
          AlternativeEserciziTableData
        > {
  $$AlternativeEserciziTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $EserciziTableTable _idEsercizioTable(_$AppDatabase db) => db
      .eserciziTable
      .createAlias('alternative_esercizi__id_esercizio__esercizi__id');

  $$EserciziTableTableProcessedTableManager get idEsercizio {
    final $_column = $_itemColumn<int>('id_esercizio')!;

    final manager = $$EserciziTableTableTableManager(
      $_db,
      $_db.eserciziTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_idEsercizioTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $EserciziTableTable _idEsercizioAlternativoTable(_$AppDatabase db) =>
      db.eserciziTable.createAlias(
        'alternative_esercizi__id_esercizio_alternativo__esercizi__id',
      );

  $$EserciziTableTableProcessedTableManager get idEsercizioAlternativo {
    final $_column = $_itemColumn<int>('id_esercizio_alternativo')!;

    final manager = $$EserciziTableTableTableManager(
      $_db,
      $_db.eserciziTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(
      _idEsercizioAlternativoTable($_db),
    );
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AlternativeEserciziTableTableFilterComposer
    extends Composer<_$AppDatabase, $AlternativeEserciziTableTable> {
  $$AlternativeEserciziTableTableFilterComposer({
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

  ColumnFilters<String> get codiceMotivo => $composableBuilder(
    column: $table.codiceMotivo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get priorita => $composableBuilder(
    column: $table.priorita,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get attiva => $composableBuilder(
    column: $table.attiva,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dataCreazione => $composableBuilder(
    column: $table.dataCreazione,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dataModifica => $composableBuilder(
    column: $table.dataModifica,
    builder: (column) => ColumnFilters(column),
  );

  $$EserciziTableTableFilterComposer get idEsercizio {
    final $$EserciziTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.idEsercizio,
      referencedTable: $db.eserciziTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EserciziTableTableFilterComposer(
            $db: $db,
            $table: $db.eserciziTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EserciziTableTableFilterComposer get idEsercizioAlternativo {
    final $$EserciziTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.idEsercizioAlternativo,
      referencedTable: $db.eserciziTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EserciziTableTableFilterComposer(
            $db: $db,
            $table: $db.eserciziTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AlternativeEserciziTableTableOrderingComposer
    extends Composer<_$AppDatabase, $AlternativeEserciziTableTable> {
  $$AlternativeEserciziTableTableOrderingComposer({
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

  ColumnOrderings<String> get codiceMotivo => $composableBuilder(
    column: $table.codiceMotivo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priorita => $composableBuilder(
    column: $table.priorita,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get attiva => $composableBuilder(
    column: $table.attiva,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dataCreazione => $composableBuilder(
    column: $table.dataCreazione,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dataModifica => $composableBuilder(
    column: $table.dataModifica,
    builder: (column) => ColumnOrderings(column),
  );

  $$EserciziTableTableOrderingComposer get idEsercizio {
    final $$EserciziTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.idEsercizio,
      referencedTable: $db.eserciziTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EserciziTableTableOrderingComposer(
            $db: $db,
            $table: $db.eserciziTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EserciziTableTableOrderingComposer get idEsercizioAlternativo {
    final $$EserciziTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.idEsercizioAlternativo,
      referencedTable: $db.eserciziTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EserciziTableTableOrderingComposer(
            $db: $db,
            $table: $db.eserciziTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AlternativeEserciziTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $AlternativeEserciziTableTable> {
  $$AlternativeEserciziTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get codiceMotivo => $composableBuilder(
    column: $table.codiceMotivo,
    builder: (column) => column,
  );

  GeneratedColumn<int> get priorita =>
      $composableBuilder(column: $table.priorita, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<bool> get attiva =>
      $composableBuilder(column: $table.attiva, builder: (column) => column);

  GeneratedColumn<DateTime> get dataCreazione => $composableBuilder(
    column: $table.dataCreazione,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dataModifica => $composableBuilder(
    column: $table.dataModifica,
    builder: (column) => column,
  );

  $$EserciziTableTableAnnotationComposer get idEsercizio {
    final $$EserciziTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.idEsercizio,
      referencedTable: $db.eserciziTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EserciziTableTableAnnotationComposer(
            $db: $db,
            $table: $db.eserciziTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EserciziTableTableAnnotationComposer get idEsercizioAlternativo {
    final $$EserciziTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.idEsercizioAlternativo,
      referencedTable: $db.eserciziTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EserciziTableTableAnnotationComposer(
            $db: $db,
            $table: $db.eserciziTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AlternativeEserciziTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AlternativeEserciziTableTable,
          AlternativeEserciziTableData,
          $$AlternativeEserciziTableTableFilterComposer,
          $$AlternativeEserciziTableTableOrderingComposer,
          $$AlternativeEserciziTableTableAnnotationComposer,
          $$AlternativeEserciziTableTableCreateCompanionBuilder,
          $$AlternativeEserciziTableTableUpdateCompanionBuilder,
          (
            AlternativeEserciziTableData,
            $$AlternativeEserciziTableTableReferences,
          ),
          AlternativeEserciziTableData,
          PrefetchHooks Function({
            bool idEsercizio,
            bool idEsercizioAlternativo,
          })
        > {
  $$AlternativeEserciziTableTableTableManager(
    _$AppDatabase db,
    $AlternativeEserciziTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AlternativeEserciziTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$AlternativeEserciziTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$AlternativeEserciziTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> idEsercizio = const Value.absent(),
                Value<int> idEsercizioAlternativo = const Value.absent(),
                Value<String> codiceMotivo = const Value.absent(),
                Value<int> priorita = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<bool> attiva = const Value.absent(),
                Value<DateTime> dataCreazione = const Value.absent(),
                Value<DateTime> dataModifica = const Value.absent(),
              }) => AlternativeEserciziTableCompanion(
                id: id,
                idEsercizio: idEsercizio,
                idEsercizioAlternativo: idEsercizioAlternativo,
                codiceMotivo: codiceMotivo,
                priorita: priorita,
                note: note,
                attiva: attiva,
                dataCreazione: dataCreazione,
                dataModifica: dataModifica,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int idEsercizio,
                required int idEsercizioAlternativo,
                required String codiceMotivo,
                Value<int> priorita = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<bool> attiva = const Value.absent(),
                required DateTime dataCreazione,
                required DateTime dataModifica,
              }) => AlternativeEserciziTableCompanion.insert(
                id: id,
                idEsercizio: idEsercizio,
                idEsercizioAlternativo: idEsercizioAlternativo,
                codiceMotivo: codiceMotivo,
                priorita: priorita,
                note: note,
                attiva: attiva,
                dataCreazione: dataCreazione,
                dataModifica: dataModifica,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AlternativeEserciziTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({idEsercizio = false, idEsercizioAlternativo = false}) {
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
                        if (idEsercizio) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.idEsercizio,
                                    referencedTable:
                                        $$AlternativeEserciziTableTableReferences
                                            ._idEsercizioTable(db),
                                    referencedColumn:
                                        $$AlternativeEserciziTableTableReferences
                                            ._idEsercizioTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (idEsercizioAlternativo) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.idEsercizioAlternativo,
                                    referencedTable:
                                        $$AlternativeEserciziTableTableReferences
                                            ._idEsercizioAlternativoTable(db),
                                    referencedColumn:
                                        $$AlternativeEserciziTableTableReferences
                                            ._idEsercizioAlternativoTable(db)
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

typedef $$AlternativeEserciziTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AlternativeEserciziTableTable,
      AlternativeEserciziTableData,
      $$AlternativeEserciziTableTableFilterComposer,
      $$AlternativeEserciziTableTableOrderingComposer,
      $$AlternativeEserciziTableTableAnnotationComposer,
      $$AlternativeEserciziTableTableCreateCompanionBuilder,
      $$AlternativeEserciziTableTableUpdateCompanionBuilder,
      (AlternativeEserciziTableData, $$AlternativeEserciziTableTableReferences),
      AlternativeEserciziTableData,
      PrefetchHooks Function({bool idEsercizio, bool idEsercizioAlternativo})
    >;
typedef $$VersioniCatalogoTableTableCreateCompanionBuilder =
    VersioniCatalogoTableCompanion Function({
      Value<int> id,
      required String tipoCatalogo,
      required int versione,
      required DateTime dataImportazione,
      Value<String?> checksum,
      Value<String?> note,
    });
typedef $$VersioniCatalogoTableTableUpdateCompanionBuilder =
    VersioniCatalogoTableCompanion Function({
      Value<int> id,
      Value<String> tipoCatalogo,
      Value<int> versione,
      Value<DateTime> dataImportazione,
      Value<String?> checksum,
      Value<String?> note,
    });

class $$VersioniCatalogoTableTableFilterComposer
    extends Composer<_$AppDatabase, $VersioniCatalogoTableTable> {
  $$VersioniCatalogoTableTableFilterComposer({
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

  ColumnFilters<String> get tipoCatalogo => $composableBuilder(
    column: $table.tipoCatalogo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get versione => $composableBuilder(
    column: $table.versione,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dataImportazione => $composableBuilder(
    column: $table.dataImportazione,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get checksum => $composableBuilder(
    column: $table.checksum,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VersioniCatalogoTableTableOrderingComposer
    extends Composer<_$AppDatabase, $VersioniCatalogoTableTable> {
  $$VersioniCatalogoTableTableOrderingComposer({
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

  ColumnOrderings<String> get tipoCatalogo => $composableBuilder(
    column: $table.tipoCatalogo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get versione => $composableBuilder(
    column: $table.versione,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dataImportazione => $composableBuilder(
    column: $table.dataImportazione,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get checksum => $composableBuilder(
    column: $table.checksum,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VersioniCatalogoTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $VersioniCatalogoTableTable> {
  $$VersioniCatalogoTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tipoCatalogo => $composableBuilder(
    column: $table.tipoCatalogo,
    builder: (column) => column,
  );

  GeneratedColumn<int> get versione =>
      $composableBuilder(column: $table.versione, builder: (column) => column);

  GeneratedColumn<DateTime> get dataImportazione => $composableBuilder(
    column: $table.dataImportazione,
    builder: (column) => column,
  );

  GeneratedColumn<String> get checksum =>
      $composableBuilder(column: $table.checksum, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);
}

class $$VersioniCatalogoTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VersioniCatalogoTableTable,
          VersioniCatalogoTableData,
          $$VersioniCatalogoTableTableFilterComposer,
          $$VersioniCatalogoTableTableOrderingComposer,
          $$VersioniCatalogoTableTableAnnotationComposer,
          $$VersioniCatalogoTableTableCreateCompanionBuilder,
          $$VersioniCatalogoTableTableUpdateCompanionBuilder,
          (
            VersioniCatalogoTableData,
            BaseReferences<
              _$AppDatabase,
              $VersioniCatalogoTableTable,
              VersioniCatalogoTableData
            >,
          ),
          VersioniCatalogoTableData,
          PrefetchHooks Function()
        > {
  $$VersioniCatalogoTableTableTableManager(
    _$AppDatabase db,
    $VersioniCatalogoTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VersioniCatalogoTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$VersioniCatalogoTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$VersioniCatalogoTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> tipoCatalogo = const Value.absent(),
                Value<int> versione = const Value.absent(),
                Value<DateTime> dataImportazione = const Value.absent(),
                Value<String?> checksum = const Value.absent(),
                Value<String?> note = const Value.absent(),
              }) => VersioniCatalogoTableCompanion(
                id: id,
                tipoCatalogo: tipoCatalogo,
                versione: versione,
                dataImportazione: dataImportazione,
                checksum: checksum,
                note: note,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String tipoCatalogo,
                required int versione,
                required DateTime dataImportazione,
                Value<String?> checksum = const Value.absent(),
                Value<String?> note = const Value.absent(),
              }) => VersioniCatalogoTableCompanion.insert(
                id: id,
                tipoCatalogo: tipoCatalogo,
                versione: versione,
                dataImportazione: dataImportazione,
                checksum: checksum,
                note: note,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VersioniCatalogoTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VersioniCatalogoTableTable,
      VersioniCatalogoTableData,
      $$VersioniCatalogoTableTableFilterComposer,
      $$VersioniCatalogoTableTableOrderingComposer,
      $$VersioniCatalogoTableTableAnnotationComposer,
      $$VersioniCatalogoTableTableCreateCompanionBuilder,
      $$VersioniCatalogoTableTableUpdateCompanionBuilder,
      (
        VersioniCatalogoTableData,
        BaseReferences<
          _$AppDatabase,
          $VersioniCatalogoTableTable,
          VersioniCatalogoTableData
        >,
      ),
      VersioniCatalogoTableData,
      PrefetchHooks Function()
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
  $$CategorieEserciziTableTableTableManager get categorieEserciziTable =>
      $$CategorieEserciziTableTableTableManager(
        _db,
        _db.categorieEserciziTable,
      );
  $$GruppiMuscolariTableTableTableManager get gruppiMuscolariTable =>
      $$GruppiMuscolariTableTableTableManager(_db, _db.gruppiMuscolariTable);
  $$EserciziTableTableTableManager get eserciziTable =>
      $$EserciziTableTableTableManager(_db, _db.eserciziTable);
  $$EserciziGruppiMuscolariTableTableTableManager
  get eserciziGruppiMuscolariTable =>
      $$EserciziGruppiMuscolariTableTableTableManager(
        _db,
        _db.eserciziGruppiMuscolariTable,
      );
  $$AttrezzatureTableTableTableManager get attrezzatureTable =>
      $$AttrezzatureTableTableTableManager(_db, _db.attrezzatureTable);
  $$AttrezzatureEserciziTableTableTableManager get attrezzatureEserciziTable =>
      $$AttrezzatureEserciziTableTableTableManager(
        _db,
        _db.attrezzatureEserciziTable,
      );
  $$ImmaginiEserciziTableTableTableManager get immaginiEserciziTable =>
      $$ImmaginiEserciziTableTableTableManager(_db, _db.immaginiEserciziTable);
  $$ProgressioniEserciziTableTableTableManager get progressioniEserciziTable =>
      $$ProgressioniEserciziTableTableTableManager(
        _db,
        _db.progressioniEserciziTable,
      );
  $$AlternativeEserciziTableTableTableManager get alternativeEserciziTable =>
      $$AlternativeEserciziTableTableTableManager(
        _db,
        _db.alternativeEserciziTable,
      );
  $$VersioniCatalogoTableTableTableManager get versioniCatalogoTable =>
      $$VersioniCatalogoTableTableTableManager(_db, _db.versioniCatalogoTable);
}
