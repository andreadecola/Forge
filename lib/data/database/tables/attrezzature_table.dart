import 'package:drift/drift.dart';

/// Catalogo master dell'attrezzatura (non rappresenta ciò che l'utente
/// possiede: per quello vedi `attrezzature_utente`, tabella della
/// Milestone 2 rinominata in italiano in questa milestone).
class AttrezzatureTable extends Table {
  @override
  String get tableName => 'attrezzature';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get codice => text().unique()();
  TextColumn get nome => text()();
  TextColumn get descrizione => text().nullable()();
  TextColumn get categoria => text().nullable()();
  RealColumn get prezzoMinimoIndicativo => real().nullable()();
  RealColumn get prezzoMassimoIndicativo => real().nullable()();
  IntColumn get priorita => integer().withDefault(const Constant(0))();
  TextColumn get queryRicerca => text().nullable()();
  BoolColumn get attiva => boolean().withDefault(const Constant(true))();
  IntColumn get versioneCatalogo => integer()();
  DateTimeColumn get dataCreazione => dateTime()();
  DateTimeColumn get dataModifica => dateTime()();
}
