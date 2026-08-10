import 'package:drift/drift.dart';

import 'allenamenti_table.dart';
import 'esercizi_table.dart';

/// Riga di scheda: un esercizio del catalogo inserito in un allenamento,
/// con solo ciò che può variare da una scheda all'altra (ordine, serie,
/// ripetizioni, durata, recupero, note). Il resto (nome, istruzioni,
/// muscoli, immagini) si legge tramite [idEsercizio] -> `esercizi`
/// (Milestone 4.1: solo struttura dati, nessun DAO/repository/UI).
@TableIndex(
  name: 'idx_allenamenti_esercizi_id_allenamento',
  columns: {#idAllenamento},
)
@TableIndex(
  name: 'idx_allenamenti_esercizi_id_esercizio',
  columns: {#idEsercizio},
)
class AllenamentiEserciziTable extends Table {
  @override
  String get tableName => 'allenamenti_esercizi';

  IntColumn get id => integer().autoIncrement()();

  /// Cancellare un allenamento elimina le sue righe scheda: non ha senso
  /// che una riga di scheda sopravviva senza la scheda che la contiene.
  IntColumn get idAllenamento => integer().references(
    AllenamentiTable,
    #id,
    onDelete: KeyAction.cascade,
  )();

  /// Nessun cascade: l'esercizio è il catalogo master condiviso, non deve
  /// mai essere eliminato "per colpa" di una scheda che lo referenzia
  /// (con i vincoli FK attivi, un tentativo di eliminarlo mentre è ancora
  /// usato in una scheda viene semplicemente rifiutato).
  IntColumn get idEsercizio => integer().references(EserciziTable, #id)();

  IntColumn get ordine => integer()();

  IntColumn get serie => integer().nullable()();
  IntColumn get ripetizioni => integer().nullable()();
  IntColumn get durataSecondi => integer().nullable()();
  IntColumn get recuperoSecondi => integer().nullable()();

  TextColumn get note => text().nullable()();

  BoolColumn get attivo => boolean().withDefault(const Constant(true))();

  DateTimeColumn get dataCreazione => dateTime()();
  DateTimeColumn get dataModifica => dateTime()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {idAllenamento, ordine},
  ];

  @override
  List<String> get customConstraints => [
    'CHECK (ordine > 0)',
    'CHECK (serie IS NULL OR serie > 0)',
    'CHECK (ripetizioni IS NULL OR ripetizioni > 0)',
    'CHECK (durata_secondi IS NULL OR durata_secondi > 0)',
    'CHECK (recupero_secondi IS NULL OR recupero_secondi >= 0)',
  ];
}
