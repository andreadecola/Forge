import 'package:drift/drift.dart';

/// Gruppi muscolari target degli esercizi (es. QUADRICIPITI, GLUTEI, ...).
class GruppiMuscolariTable extends Table {
  @override
  String get tableName => 'gruppi_muscolari';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get codice => text().unique()();
  TextColumn get nome => text()();
  TextColumn get descrizione => text().nullable()();
  BoolColumn get attivo => boolean().withDefault(const Constant(true))();
  DateTimeColumn get dataCreazione => dateTime()();
  DateTimeColumn get dataModifica => dateTime()();
}
