import 'package:drift/drift.dart';

import 'attrezzature_table.dart';
import 'esercizi_table.dart';

/// Relazione molti-a-molti esercizio <-> attrezzatura richiesta.
@TableIndex(name: 'idx_ae_id_esercizio', columns: {#idEsercizio})
@TableIndex(name: 'idx_ae_id_attrezzatura', columns: {#idAttrezzatura})
class AttrezzatureEserciziTable extends Table {
  @override
  String get tableName => 'attrezzature_esercizi';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get idEsercizio => integer().references(EserciziTable, #id)();
  IntColumn get idAttrezzatura =>
      integer().references(AttrezzatureTable, #id)();
  BoolColumn get obbligatoria => boolean().withDefault(const Constant(true))();

  @override
  List<Set<Column>> get uniqueKeys => [
    {idEsercizio, idAttrezzatura},
  ];
}
