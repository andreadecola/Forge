import 'package:drift/drift.dart';

/// Traccia quale versione di ciascun catalogo (es. ESERCIZI) è stata
/// importata, per rendere il seed idempotente e verificabile.
class VersioniCatalogoTable extends Table {
  @override
  String get tableName => 'versioni_catalogo';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get tipoCatalogo => text()();
  IntColumn get versione => integer()();
  DateTimeColumn get dataImportazione => dateTime()();
  TextColumn get checksum => text().nullable()();
  TextColumn get note => text().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {tipoCatalogo, versione},
  ];
}
