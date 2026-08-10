import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../../core/constants/app_constants.dart';
import 'daos/alternative_esercizi_dao.dart';
import 'daos/app_settings_dao.dart';
import 'daos/attrezzature_dao.dart';
import 'daos/body_measurements_dao.dart';
import 'daos/categorie_esercizi_dao.dart';
import 'daos/esercizi_dao.dart';
import 'daos/gruppi_muscolari_dao.dart';
import 'daos/immagini_esercizi_dao.dart';
import 'daos/pressure_measurements_dao.dart';
import 'daos/progressioni_esercizi_dao.dart';
import 'daos/user_equipment_dao.dart';
import 'daos/user_profile_dao.dart';
import 'tables/alternative_esercizi_table.dart';
import 'tables/app_settings_table.dart';
import 'tables/attrezzature_esercizi_table.dart';
import 'tables/attrezzature_table.dart';
import 'tables/body_measurements_table.dart';
import 'tables/categorie_esercizi_table.dart';
import 'tables/esercizi_gruppi_muscolari_table.dart';
import 'tables/esercizi_table.dart';
import 'tables/gruppi_muscolari_table.dart';
import 'tables/immagini_esercizi_table.dart';
import 'tables/pressure_measurements_table.dart';
import 'tables/progressioni_esercizi_table.dart';
import 'tables/user_equipment_table.dart';
import 'tables/user_profiles_table.dart';
import 'tables/versioni_catalogo_table.dart';

part 'app_database.g.dart';

/// Database Drift applicativo.
///
/// - Milestone 2 (schema 1): profilo utente, misure corporee, pressione,
///   attrezzatura utente, impostazioni. Tabelle rinominate in italiano
///   nella Milestone 3.1 (vedi [migration]).
/// - Milestone 3.1 (schema 2): struttura del catalogo esercizi (categorie,
///   gruppi muscolari, esercizi, relazioni, immagini, progressioni,
///   alternative, versionamento). Nessun dato ancora importato: il seed
///   arriva con la Milestone 3.2.
@DriftDatabase(
  tables: [
    AppSettingsTable,
    UserProfilesTable,
    BodyMeasurementsTable,
    PressureMeasurementsTable,
    UserEquipmentTable,
    CategorieEserciziTable,
    GruppiMuscolariTable,
    EserciziTable,
    EserciziGruppiMuscolariTable,
    AttrezzatureTable,
    AttrezzatureEserciziTable,
    ImmaginiEserciziTable,
    ProgressioniEserciziTable,
    AlternativeEserciziTable,
    VersioniCatalogoTable,
  ],
  daos: [
    AppSettingsDao,
    UserProfileDao,
    BodyMeasurementsDao,
    PressureMeasurementsDao,
    UserEquipmentDao,
    CategorieEserciziDao,
    GruppiMuscolariDao,
    AttrezzatureDao,
    EserciziDao,
    ImmaginiEserciziDao,
    ProgressioniEserciziDao,
    AlternativeEserciziDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) => m.createAll(),
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        // Le tabelle Milestone 2 esistevano già con nomi fisici inglesi:
        // rinominarle preserva tutte le righe, le primary key e le
        // relazioni (SQLite aggiorna automaticamente i riferimenti FK).
        await m.renameTable(userProfilesTable, 'user_profiles_table');
        await m.renameTable(bodyMeasurementsTable, 'body_measurements_table');
        await m.renameTable(
          pressureMeasurementsTable,
          'pressure_measurements_table',
        );
        await m.renameTable(userEquipmentTable, 'user_equipment_table');
        await m.renameTable(appSettingsTable, 'app_settings_table');

        // Crea solo le tabelle/indici del catalogo esercizi: le tabelle
        // rinominate sopra esistono già, createAll() è idempotente
        // (CREATE TABLE/INDEX IF NOT EXISTS) e non le tocca.
        await m.createAll();
      }
    },
  );

  static QueryExecutor _openConnection() {
    return driftDatabase(name: AppConstants.databaseName);
  }
}
