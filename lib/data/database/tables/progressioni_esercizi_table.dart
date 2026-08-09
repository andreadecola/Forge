import 'package:drift/drift.dart';

import 'esercizi_table.dart';

/// Grafo di progressione tra esercizi (A -> B). La regressione (B -> A) si
/// ottiene interrogando questa stessa tabella al contrario: non esiste una
/// tabella `regressioni_esercizi` separata (vedi 05_Forge_Engine.md).
@TableIndex(name: 'idx_progressioni_id_esercizio', columns: {#idEsercizio})
class ProgressioniEserciziTable extends Table {
  @override
  String get tableName => 'progressioni_esercizi';

  IntColumn get id => integer().autoIncrement()();

  @ReferenceName('progressioniComePrecedente')
  IntColumn get idEsercizio => integer().references(EserciziTable, #id)();

  @ReferenceName('progressioniComeSuccessivo')
  IntColumn get idEsercizioSuccessivo =>
      integer().references(EserciziTable, #id)();

  /// Codice stabile di [ExerciseProgressionType].
  TextColumn get tipoProgressione => text()();

  IntColumn get livelloMinimo => integer()();
  IntColumn get priorita => integer().withDefault(const Constant(0))();
  TextColumn get note => text().nullable()();
  BoolColumn get attiva => boolean().withDefault(const Constant(true))();

  DateTimeColumn get dataCreazione => dateTime()();
  DateTimeColumn get dataModifica => dateTime()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {idEsercizio, idEsercizioSuccessivo},
  ];

  @override
  List<String> get customConstraints => [
    'CHECK (id_esercizio != id_esercizio_successivo)',
  ];
}
