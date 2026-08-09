import 'package:drift/drift.dart';

import 'esercizi_table.dart';

/// Immagini associate a un esercizio (copertina, posizione iniziale/finale,
/// movimento, errore comune, sicurezza). Per la v1 si usano principalmente
/// asset locali (vedi [ExerciseImageSourceType]).
@TableIndex(name: 'idx_immagini_esercizi_id_esercizio', columns: {#idEsercizio})
class ImmaginiEserciziTable extends Table {
  @override
  String get tableName => 'immagini_esercizi';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get idEsercizio => integer().references(EserciziTable, #id)();

  /// Codice stabile di [ExerciseImageSourceType].
  TextColumn get tipoSorgente => text()();

  TextColumn get percorsoAsset => text().nullable()();
  TextColumn get percorsoFileLocale => text().nullable()();

  /// Codice stabile di [ExerciseImageType].
  TextColumn get tipoImmagine => text()();

  TextColumn get didascalia => text().nullable()();
  IntColumn get ordineVisualizzazione =>
      integer().withDefault(const Constant(0))();
  BoolColumn get attiva => boolean().withDefault(const Constant(true))();

  DateTimeColumn get dataCreazione => dateTime()();
  DateTimeColumn get dataModifica => dateTime()();
}
