import 'package:drift/drift.dart';

import 'user_profiles_table.dart';

/// Nome fisico SQLite in italiano (Milestone 3.1).
///
/// Indice su (profileId, measuredAt) aggiunto in Milestone 7.1: stesso
/// motivo di `BodyMeasurementsTable` — lo storico per profilo è già
/// interrogato ordinato per data, senza indice dedicato da Milestone 2.
@TableIndex(
  name: 'idx_misurazioni_pressione_profilo_data',
  columns: {#profileId, #measuredAt},
)
class PressureMeasurementsTable extends Table {
  @override
  String get tableName => 'misurazioni_pressione';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get profileId => integer().references(UserProfilesTable, #id)();
  DateTimeColumn get measuredAt => dateTime()();
  IntColumn get systolic => integer()();
  IntColumn get diastolic => integer()();
  IntColumn get heartRate => integer().nullable()();
  TextColumn get measurementContext => text().nullable()();
  TextColumn get notes => text().nullable()();
}
