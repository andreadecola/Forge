import 'package:drift/drift.dart';

import 'categorie_esercizi_table.dart';

/// Anagrafica esercizi del catalogo Forge. Vedi 06_Exercise_Catalog.md.
@TableIndex(name: 'idx_esercizi_id_categoria', columns: {#idCategoria})
@TableIndex(name: 'idx_esercizi_livello_minimo', columns: {#livelloMinimo})
@TableIndex(name: 'idx_esercizi_attivo', columns: {#attivo})
class EserciziTable extends Table {
  @override
  String get tableName => 'esercizi';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get codice => text().unique()();
  TextColumn get nome => text()();
  TextColumn get descrizione => text()();
  TextColumn get istruzioni => text()();
  TextColumn get istruzioniRespirazione => text().nullable()();
  TextColumn get noteSicurezza => text().nullable()();
  TextColumn get erroriComuni => text().nullable()();

  IntColumn get idCategoria =>
      integer().references(CategorieEserciziTable, #id)();

  IntColumn get livelloMinimo => integer()();
  IntColumn get livelloMassimo => integer().nullable()();

  /// Codice stabile di [ExerciseImpactLevel].
  TextColumn get livelloImpatto => text()();

  /// Intensità cardio: stesso vocabolario di [ExerciseImpactLevel]
  /// (VERY_LOW/LOW/MODERATE/HIGH), non ancora un enum dedicato.
  TextColumn get intensitaCardio => text().nullable()();

  BoolColumn get richiedeEquilibrio =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get richiedePavimento =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get richiedePosizioneEretta =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get supportoConsentito =>
      boolean().withDefault(const Constant(false))();

  IntColumn get seriePredefinite => integer().nullable()();
  IntColumn get ripetizioniPredefinite => integer().nullable()();
  IntColumn get durataPredefinitaSecondi => integer().nullable()();
  IntColumn get recuperoPredefinitoSecondi => integer().nullable()();

  BoolColumn get esercizioSistema =>
      boolean().withDefault(const Constant(true))();
  BoolColumn get attivo => boolean().withDefault(const Constant(true))();

  IntColumn get versioneCatalogo => integer()();

  DateTimeColumn get dataCreazione => dateTime()();
  DateTimeColumn get dataModifica => dateTime()();
}
