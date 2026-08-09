import 'package:drift/drift.dart';

/// Categorie del catalogo esercizi (es. MOBILITA, GAMBE_GLUTEI, ...).
/// Vedi 06_Exercise_Catalog.md.
class CategorieEserciziTable extends Table {
  @override
  String get tableName => 'categorie_esercizi';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get codice => text().unique()();
  TextColumn get nome => text()();
  TextColumn get descrizione => text().nullable()();
  IntColumn get ordineVisualizzazione =>
      integer().withDefault(const Constant(0))();
  BoolColumn get attiva => boolean().withDefault(const Constant(true))();
  DateTimeColumn get dataCreazione => dateTime()();
  DateTimeColumn get dataModifica => dateTime()();
}
