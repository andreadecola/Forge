import 'package:drift/drift.dart';

import 'allenamenti_table.dart';
import 'camminate_table.dart';
import 'sessioni_allenamento_table.dart';
import 'user_profiles_table.dart';

/// Fondamenta del Piano Settimanale (Milestone 8.1): rappresenta solo "cosa
/// è previsto per una data", mai "cosa è realmente successo" — quella resta
/// competenza esclusiva di `sessioni_allenamento`/`camminate` (Milestone
/// 4/6), che questa tabella non duplica in alcuna colonna.
///
/// `stato` ammette `PLANNED`/`SKIPPED`/`POSTPONED` da Milestone 8.6 (schema
/// 11): nessun valore per il completamento, sempre derivato dalla sessione
/// reale collegata (Milestone 8.5). Il CHECK non può essere allargato con
/// un `ALTER TABLE` diretto (SQLite non lo supporta su un CHECK esistente):
/// la migration 10->11 usa `Migrator.alterTable(TableMigration(...))`, che
/// applica la procedura standard SQLite di ricreazione tabella.
@TableIndex(
  name: 'idx_attivita_pianificate_profilo_data',
  columns: {#idProfilo, #dataPianificata},
)
class AttivitaPianificateTable extends Table {
  @override
  String get tableName => 'attivita_pianificate';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get idProfilo => integer().references(UserProfilesTable, #id)();

  /// Solo il giorno (mezzanotte locale): vedi [PlannedActivity.scheduledDate].
  DateTimeColumn get dataPianificata => dateTime()();

  /// Codice stabile di `PlannedActivityType`.
  TextColumn get tipo => text()();

  /// Riferimento a `allenamenti.id`, obbligatorio solo per `tipo = WORKOUT`
  /// (validato dal dominio, non da un CHECK incrociato — stesso principio
  /// già seguito per `allenamenti_esercizi`). `SET NULL` invece di CASCADE:
  /// eliminare la scheda non deve eliminare né bloccare l'attività
  /// pianificata (sezione 20/57), stesso pattern già usato da
  /// `sessioni_allenamento.idAllenamento`.
  IntColumn get idAllenamento => integer().nullable().references(
    AllenamentiTable,
    #id,
    onDelete: KeyAction.setNull,
  )();

  /// Solo per `tipo = WALK` (sezione 16): durata prevista, mai un target di
  /// distanza/passi — nessuna duplicazione dei campi di `camminate`.
  IntColumn get durataPianificataMinuti => integer().nullable()();

  /// Codice stabile di `PlannedActivityStatus`.
  TextColumn get stato => text().withDefault(const Constant('PLANNED'))();

  /// Codice stabile di `PlannedActivityOrigin`.
  TextColumn get origine => text()();

  TextColumn get note => text().nullable()();

  DateTimeColumn get dataCreazione => dateTime()();
  DateTimeColumn get dataModifica => dateTime()();

  /// Collegamento esplicito alla `WorkoutSession` reale nata avviando
  /// questa attività (Milestone 8.5): valorizzato solo per `tipo =
  /// WORKOUT`, mai dedotto da data/workoutId/durata (nessun matching
  /// implicito, sezione 15). Un solo valore alla volta: rappresenta la
  /// sessione corrente/più recente, non uno storico — un nuovo avvio dopo
  /// un abort sovrascrive il riferimento, ma la sessione precedente resta
  /// comunque nello storico di `sessioni_allenamento` (mai eliminata,
  /// sezione 25/26). `SET NULL` invece di CASCADE: coerente con
  /// `idAllenamento` sopra — eliminare l'attività pianificata non deve mai
  /// eliminare la sessione reale (sezione 27).
  IntColumn get idSessioneAllenamento => integer().nullable().references(
    SessioniAllenamentoTable,
    #id,
    onDelete: KeyAction.setNull,
  )();

  /// Stesso principio per `tipo = WALK`.
  IntColumn get idSessioneCamminata => integer().nullable().references(
    CamminateTable,
    #id,
    onDelete: KeyAction.setNull,
  )();

  @override
  List<String> get customConstraints => [
    "CHECK (tipo IN ('WORKOUT', 'WALK', 'RECOVERY'))",
    "CHECK (stato IN ('PLANNED', 'SKIPPED', 'POSTPONED'))",
    "CHECK (origine IN ('USER', 'FORGE_ENGINE'))",
    'CHECK (durata_pianificata_minuti IS NULL OR durata_pianificata_minuti > 0)',
  ];
}
