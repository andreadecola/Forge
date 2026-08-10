import 'package:drift/drift.dart';

import 'allenamenti_table.dart';
import 'user_profiles_table.dart';

/// Sessione di esecuzione di una scheda (Milestone 4.4.3): persiste ciò che
/// serve a ripristinare un allenamento in corso dopo la chiusura dell'app.
/// Non è la DEFINIZIONE della scheda ([AllenamentiTable]): questa tabella
/// registra invece lo storico di esecuzione (Milestone 4.4.1/4.4.2,
/// `WorkoutSessionState`).
///
/// [idAllenamento] è nullable con `ON DELETE SET NULL`: l'hard delete di una
/// scheda (già disponibile dalla Milestone 4.3.1 per le schede archiviate)
/// non deve né essere bloccato né cancellare lo storico delle sessioni —
/// la riga sopravvive "orfana", restando comunque leggibile grazie a
/// [nomeAllenamentoSnapshot] e ai parametri snapshot in
/// [SessioniEserciziTable]. Vedi 07_Training_Engine.md per il confronto
/// con le alternative (CASCADE, RESTRICT) scartate.
///
/// Nessuna colonna "fase": a differenza di `WorkoutSessionPhase` (UI), qui
/// non viene persistito alcuno stato ridondante — la fase runtime si deriva
/// sempre da [stato]/[inPausa]/[timerTipo], stesso principio di
/// "nessuno stato duplicato" già seguito da `WorkoutSessionState.phase`
/// (Milestone 4.4.2).
@TableIndex(
  name: 'idx_sessioni_allenamento_id_allenamento',
  columns: {#idAllenamento},
)
@TableIndex(name: 'idx_sessioni_allenamento_id_profilo', columns: {#idProfilo})
@TableIndex(name: 'idx_sessioni_allenamento_stato', columns: {#stato})
class SessioniAllenamentoTable extends Table {
  @override
  String get tableName => 'sessioni_allenamento';

  IntColumn get id => integer().autoIncrement()();

  IntColumn get idAllenamento => integer().nullable().references(
    AllenamentiTable,
    #id,
    onDelete: KeyAction.setNull,
  )();

  IntColumn get idProfilo => integer().references(UserProfilesTable, #id)();

  /// Nome della scheda al momento dell'avvio: la scheda può essere
  /// rinominata (o eliminata) dopo, ma lo storico deve restare leggibile
  /// con il nome usato quando la sessione è iniziata (sezione 7).
  TextColumn get nomeAllenamentoSnapshot => text()();

  /// Codice stabile di `WorkoutSessionPersistenceStatus`
  /// (IN_PROGRESS/PAUSED/COMPLETED/ABORTED).
  TextColumn get stato => text()();

  IntColumn get indiceEsercizioCorrente =>
      integer().withDefault(const Constant(0))();

  DateTimeColumn get dataInizio => dateTime()();
  DateTimeColumn get dataFine => dateTime().nullable()();

  BoolColumn get inPausa => boolean().withDefault(const Constant(false))();
  BoolColumn get completata => boolean().withDefault(const Constant(false))();

  /// Timer attivo (serie a tempo o recupero), se presente: al più uno dei
  /// due può essere in corso alla volta (stesso invariante di
  /// `WorkoutSessionState.exerciseTimer`/`restTimer`), quindi un'unica
  /// terna di colonne basta — `null` in [timerTipo] significa "nessun
  /// timer attivo" (equivalente al valore concettuale "NONE" citato nello
  /// spec: qui reso come assenza, non come stringa magica, per coerenza
  /// con il resto dello schema).
  TextColumn get timerTipo => text().nullable()();
  DateTimeColumn get timerStartedAt => dateTime().nullable()();
  IntColumn get timerTargetSeconds => integer().nullable()();

  /// Non nullo solo quando il timer è in pausa: i secondi residui
  /// congelati (stesso significato di `SessionTimer.pausedRemainingSeconds`).
  IntColumn get timerRemainingPaused => integer().nullable()();

  DateTimeColumn get dataCreazione => dateTime()();
  DateTimeColumn get dataModifica => dateTime()();

  @override
  List<String> get customConstraints => [
    'CHECK (indice_esercizio_corrente >= 0)',
    'CHECK (timer_target_seconds IS NULL OR timer_target_seconds > 0)',
    'CHECK (timer_remaining_paused IS NULL OR timer_remaining_paused >= 0)',
  ];
}
