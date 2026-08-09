import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../../core/constants/app_constants.dart';
import 'tables/app_settings_table.dart';

part 'app_database.g.dart';

/// Database Drift della baseline (Milestone 1).
/// Contiene solo una tabella tecnica minimale per validare la connessione:
/// lo schema definitivo verrà introdotto nella Milestone 2.
@DriftDatabase(tables: [AppSettingsTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(name: AppConstants.databaseName);
  }
}
