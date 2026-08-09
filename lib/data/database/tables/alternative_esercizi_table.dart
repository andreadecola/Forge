import 'package:drift/drift.dart';

import 'esercizi_table.dart';

/// Alternative proposte tra esercizi (non equivalenze mediche: servono al
/// futuro Forge Engine come opzioni di programmazione).
@TableIndex(name: 'idx_alternative_id_esercizio', columns: {#idEsercizio})
class AlternativeEserciziTable extends Table {
  @override
  String get tableName => 'alternative_esercizi';

  IntColumn get id => integer().autoIncrement()();

  @ReferenceName('alternativeComeOriginale')
  IntColumn get idEsercizio => integer().references(EserciziTable, #id)();

  @ReferenceName('alternativeComeAlternativa')
  IntColumn get idEsercizioAlternativo =>
      integer().references(EserciziTable, #id)();

  /// Codice stabile di [ExerciseAlternativeReason].
  TextColumn get codiceMotivo => text()();

  IntColumn get priorita => integer().withDefault(const Constant(0))();
  TextColumn get note => text().nullable()();
  BoolColumn get attiva => boolean().withDefault(const Constant(true))();

  DateTimeColumn get dataCreazione => dateTime()();
  DateTimeColumn get dataModifica => dateTime()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {idEsercizio, idEsercizioAlternativo, codiceMotivo},
  ];

  @override
  List<String> get customConstraints => [
    'CHECK (id_esercizio != id_esercizio_alternativo)',
  ];
}
