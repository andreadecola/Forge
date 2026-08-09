import 'package:drift/drift.dart';

import 'esercizi_table.dart';
import 'gruppi_muscolari_table.dart';

/// Relazione molti-a-molti esercizio <-> gruppo muscolare, con ruolo
/// (PRIMARIO/SECONDARIO — vedi [ExerciseMuscleRole]).
@TableIndex(name: 'idx_egm_id_esercizio', columns: {#idEsercizio})
@TableIndex(name: 'idx_egm_id_gruppo_muscolare', columns: {#idGruppoMuscolare})
class EserciziGruppiMuscolariTable extends Table {
  @override
  String get tableName => 'esercizi_gruppi_muscolari';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get idEsercizio => integer().references(EserciziTable, #id)();
  IntColumn get idGruppoMuscolare =>
      integer().references(GruppiMuscolariTable, #id)();

  /// Codice stabile di [ExerciseMuscleRole].
  TextColumn get tipoCoinvolgimento => text()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {idEsercizio, idGruppoMuscolare},
  ];
}
