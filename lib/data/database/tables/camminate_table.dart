import 'package:drift/drift.dart';

import 'user_profiles_table.dart';

/// Persisted walking sessions (Milestone 6.1).
///
/// Duration is deliberately not stored: for a finished session it is derived
/// from [dataInizio] and [dataFine], keeping one source of truth.
@TableIndex(
  name: 'idx_camminate_id_profilo_data_inizio',
  columns: {#idProfilo, #dataInizio},
)
@TableIndex.sql(
  'CREATE UNIQUE INDEX idx_camminate_attiva_per_profilo '
  'ON camminate (id_profilo) WHERE stato = \'IN_PROGRESS\'',
)
class CamminateTable extends Table {
  @override
  String get tableName => 'camminate';

  IntColumn get id => integer().autoIncrement()();

  IntColumn get idProfilo => integer().references(UserProfilesTable, #id)();

  DateTimeColumn get dataInizio => dateTime()();
  DateTimeColumn get dataFine => dateTime().nullable()();

  IntColumn get distanzaMetri => integer().nullable()();
  IntColumn get passi => integer().nullable()();

  BoolColumn get pausaInCorso => boolean().withDefault(const Constant(false))();
  DateTimeColumn get dataInizioPausa => dateTime().nullable()();
  IntColumn get durataPausaSecondi =>
      integer().withDefault(const Constant(0))();

  TextColumn get stato => text()();
  TextColumn get note => text().nullable()();

  DateTimeColumn get dataCreazione => dateTime()();
  DateTimeColumn get dataModifica => dateTime()();

  @override
  List<String> get customConstraints => [
    'CHECK (distanza_metri IS NULL OR distanza_metri >= 0)',
    'CHECK (passi IS NULL OR passi >= 0)',
    'CHECK (durata_pausa_secondi >= 0)',
    "CHECK (stato IN ('IN_PROGRESS', 'COMPLETED', 'ABORTED'))",
  ];
}
