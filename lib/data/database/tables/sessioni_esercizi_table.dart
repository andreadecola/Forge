import 'package:drift/drift.dart';

import 'allenamenti_esercizi_table.dart';
import 'esercizi_table.dart';
import 'sessioni_allenamento_table.dart';

/// Snapshot, per una sessione, di una riga scheda con il progresso serie
/// raggiunto (Milestone 4.4.3). I parametri (serie/ripetizioni/durata/
/// recupero) sono congelati al momento dell'avvio della sessione — se la
/// scheda viene modificata mentre la sessione è in corso (o dopo), questa
/// riga non cambia: la sessione continua con i parametri con cui è
/// iniziata (sezione 10/43).
///
/// [idAllenamentoEsercizio] è nullable con `ON DELETE SET NULL`, non
/// `CASCADE`: se la scheda viene eliminata, `allenamenti_esercizi` la sua
/// riga viene eliminata in CASCADE (vincolo già esistente dalla Milestone
/// 4.1), ma questa riga snapshot deve sopravvivere lo stesso (motivo
/// identico a `SessioniAllenamentoTable.idAllenamento`, vedi lì). Nessun
/// impatto pratico sulla leggibilità: tutti i valori mostrabili
/// (ordine/serie/ripetizioni/durata/recupero/progresso) sono già in questa
/// riga come snapshot.
///
/// [idEsercizio] non è nullable e non ha `ON DELETE` speciale (nessun
/// cascade): stesso comportamento di `AllenamentiEserciziTable.idEsercizio`
/// — il catalogo esercizi è master condiviso e non viene mai eliminato
/// "per colpa" di una riga che lo referenzia.
@TableIndex(name: 'idx_sessioni_esercizi_id_sessione', columns: {#idSessione})
@TableIndex(
  name: 'idx_sessioni_esercizi_id_allenamento_esercizio',
  columns: {#idAllenamentoEsercizio},
)
class SessioniEserciziTable extends Table {
  @override
  String get tableName => 'sessioni_esercizi';

  IntColumn get id => integer().autoIncrement()();

  IntColumn get idSessione => integer().references(
    SessioniAllenamentoTable,
    #id,
    onDelete: KeyAction.cascade,
  )();

  IntColumn get idAllenamentoEsercizio => integer().nullable().references(
    AllenamentiEserciziTable,
    #id,
    onDelete: KeyAction.setNull,
  )();

  IntColumn get idEsercizio => integer().references(EserciziTable, #id)();

  IntColumn get ordine => integer()();

  /// Numero di serie da eseguire, già risolto a runtime (`sets ?? 1`
  /// dell'esercizio scheda al momento dell'avvio, Milestone 4.4.2 sezione
  /// 18): a differenza di `AllenamentiEserciziTable.serie`, qui non è mai
  /// null, perché questa riga esiste solo per tracciare il progresso di
  /// una sessione già iniziata (serve sempre un totale con cui confrontare
  /// [serieCompletate]).
  IntColumn get serieTotali => integer()();

  IntColumn get serieCompletate => integer().withDefault(const Constant(0))();

  IntColumn get ripetizioni => integer().nullable()();
  IntColumn get durataSecondi => integer().nullable()();
  IntColumn get recuperoSecondi => integer().nullable()();

  BoolColumn get saltato => boolean().withDefault(const Constant(false))();
  BoolColumn get completato => boolean().withDefault(const Constant(false))();

  DateTimeColumn get dataCreazione => dateTime()();
  DateTimeColumn get dataModifica => dateTime()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {idSessione, ordine},
  ];

  @override
  List<String> get customConstraints => [
    'CHECK (ordine > 0)',
    'CHECK (serie_totali > 0)',
    'CHECK (serie_completate >= 0)',
    'CHECK (ripetizioni IS NULL OR ripetizioni > 0)',
    'CHECK (durata_secondi IS NULL OR durata_secondi > 0)',
    'CHECK (recupero_secondi IS NULL OR recupero_secondi >= 0)',
  ];
}
