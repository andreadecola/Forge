import 'package:drift/drift.dart';

/// Tabella tecnica minimale per verificare la baseline Drift.
/// Non fa parte dello schema definitivo (vedi 03_Database_Design.md), che
/// sarà introdotto nella Milestone 2.
class AppSettingsTable extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}
