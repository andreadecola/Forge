import 'package:drift/drift.dart';
import 'package:forge/data/database/tables/allenamenti_table.dart';
import 'package:forge/data/database/tables/allenamenti_esercizi_table.dart';
import 'package:forge/data/database/tables/esercizi_table.dart';
import 'package:forge/data/database/tables/user_profiles_table.dart';

/// Snapshot dello schema 4, prima del collegamento sessione → camminata.
/// Le fixture delle migrazioni walking non devono importare nuovi vincoli
/// dalle Table correnti e creare implicitamente la tabella che stanno testando.
@TableIndex(name:'idx_sessioni_allenamento_id_allenamento',columns:{#idAllenamento})
@TableIndex(name:'idx_sessioni_allenamento_id_profilo',columns:{#idProfilo})
@TableIndex(name:'idx_sessioni_allenamento_stato',columns:{#stato})
class LegacyWorkoutSessions extends Table {
  @override String get tableName=>'sessioni_allenamento';
  IntColumn get id=>integer().autoIncrement()();
  IntColumn get idAllenamento=>integer().nullable().references(AllenamentiTable,#id,onDelete:KeyAction.setNull)();
  IntColumn get idProfilo=>integer().references(UserProfilesTable,#id)();
  TextColumn get nomeAllenamentoSnapshot=>text()();
  TextColumn get stato=>text()();
  IntColumn get indiceEsercizioCorrente=>integer().withDefault(const Constant(0))();
  DateTimeColumn get dataInizio=>dateTime()();
  DateTimeColumn get dataFine=>dateTime().nullable()();
  BoolColumn get inPausa=>boolean().withDefault(const Constant(false))();
  BoolColumn get completata=>boolean().withDefault(const Constant(false))();
  TextColumn get timerTipo=>text().nullable()();
  DateTimeColumn get timerStartedAt=>dateTime().nullable()();
  IntColumn get timerTargetSeconds=>integer().nullable()();
  IntColumn get timerRemainingPaused=>integer().nullable()();
  DateTimeColumn get dataCreazione=>dateTime()();
  DateTimeColumn get dataModifica=>dateTime()();
  @override List<String> get customConstraints=>[
    'CHECK (indice_esercizio_corrente >= 0)',
    'CHECK (timer_target_seconds IS NULL OR timer_target_seconds > 0)',
    'CHECK (timer_remaining_paused IS NULL OR timer_remaining_paused >= 0)',
  ];
}

@TableIndex(name:'idx_sessioni_esercizi_id_sessione',columns:{#idSessione})
@TableIndex(name:'idx_sessioni_esercizi_id_allenamento_esercizio',columns:{#idAllenamentoEsercizio})
class LegacySessionExercises extends Table {
  @override String get tableName=>'sessioni_esercizi';
  IntColumn get id=>integer().autoIncrement()();
  IntColumn get idSessione=>integer().references(LegacyWorkoutSessions,#id,onDelete:KeyAction.cascade)();
  IntColumn get idAllenamentoEsercizio=>integer().nullable().references(AllenamentiEserciziTable,#id,onDelete:KeyAction.setNull)();
  IntColumn get idEsercizio=>integer().references(EserciziTable,#id)();
  IntColumn get ordine=>integer()();
  IntColumn get serieTotali=>integer()();
  IntColumn get serieCompletate=>integer().withDefault(const Constant(0))();
  IntColumn get ripetizioni=>integer().nullable()();
  IntColumn get durataSecondi=>integer().nullable()();
  IntColumn get recuperoSecondi=>integer().nullable()();
  BoolColumn get saltato=>boolean().withDefault(const Constant(false))();
  BoolColumn get completato=>boolean().withDefault(const Constant(false))();
  DateTimeColumn get dataCreazione=>dateTime()();
  DateTimeColumn get dataModifica=>dateTime()();
  @override List<Set<Column>> get uniqueKeys=>[{idSessione,ordine}];
  @override List<String> get customConstraints=>[
    'CHECK (ordine > 0)','CHECK (serie_totali > 0)','CHECK (serie_completate >= 0)',
    'CHECK (ripetizioni IS NULL OR ripetizioni > 0)',
    'CHECK (durata_secondi IS NULL OR durata_secondi > 0)',
    'CHECK (recupero_secondi IS NULL OR recupero_secondi >= 0)',
  ];
}
