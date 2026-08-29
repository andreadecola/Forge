import 'package:drift/drift.dart';

import 'user_profiles_table.dart';

/// Nome fisico SQLite in italiano (Milestone 3.1).
///
/// Indice su (profileId, measuredAt) aggiunto in Milestone 7.1: lo storico
/// per profilo è già interrogato ordinato per data (`getMeasurementsByProfile`/
/// `watchMeasurementsByProfile`/`getLatestWeight`), senza indice dedicato da
/// Milestone 2 — nessun cambiamento di colonne, solo una query più veloce.
@TableIndex(
  name: 'idx_misurazioni_corporee_profilo_data',
  columns: {#profileId, #measuredAt},
)
class BodyMeasurementsTable extends Table {
  @override
  String get tableName => 'misurazioni_corporee';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get profileId => integer().references(UserProfilesTable, #id)();
  DateTimeColumn get measuredAt => dateTime()();

  /// Nullable da Milestone 7.2 (schema 8): una misurazione può registrare
  /// solo il girovita, senza peso. "Almeno una metrica presente" (peso o
  /// girovita) è garantito a runtime da `OnboardingValidators.atLeastOneBodyMetric`,
  /// non più dal tipo — vedi Docs/M7_2_Weight_Waist.md per la decisione.
  RealColumn get weightKg => real().nullable()();
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
