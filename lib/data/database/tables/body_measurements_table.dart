import 'package:drift/drift.dart';

import 'user_profiles_table.dart';

/// Nome fisico SQLite in italiano (Milestone 3.1).
class BodyMeasurementsTable extends Table {
  @override
  String get tableName => 'misurazioni_corporee';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get profileId => integer().references(UserProfilesTable, #id)();
  DateTimeColumn get measuredAt => dateTime()();
  RealColumn get weightKg => real()();
  RealColumn get neckCm => real().nullable()();
  RealColumn get chestCm => real().nullable()();
  RealColumn get waistCm => real().nullable()();
  RealColumn get abdomenCm => real().nullable()();
  RealColumn get hipsCm => real().nullable()();
  RealColumn get leftArmCm => real().nullable()();
  RealColumn get rightArmCm => real().nullable()();
  RealColumn get leftThighCm => real().nullable()();
  RealColumn get rightThighCm => real().nullable()();
  RealColumn get leftCalfCm => real().nullable()();
  RealColumn get rightCalfCm => real().nullable()();
  TextColumn get notes => text().nullable()();
}
