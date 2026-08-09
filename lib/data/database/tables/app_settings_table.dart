import 'package:drift/drift.dart';

/// Impostazioni applicative chiave/valore (onboarding, tema, notifiche).
/// Nome fisico SQLite in italiano (Milestone 3.1).
class AppSettingsTable extends Table {
  @override
  String get tableName => 'impostazioni_app';

  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}
