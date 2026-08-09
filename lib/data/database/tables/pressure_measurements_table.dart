import 'package:drift/drift.dart';

import 'user_profiles_table.dart';

class PressureMeasurementsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get profileId => integer().references(UserProfilesTable, #id)();
  DateTimeColumn get measuredAt => dateTime()();
  IntColumn get systolic => integer()();
  IntColumn get diastolic => integer()();
  IntColumn get heartRate => integer().nullable()();
  TextColumn get measurementContext => text().nullable()();
  TextColumn get notes => text().nullable()();
}
