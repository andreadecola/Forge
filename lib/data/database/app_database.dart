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
import 'tables/allenamenti_esercizi_table.dart';
import 'tables/allenamenti_table.dart';
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
/// - Milestone 4.1 (schema 3): struttura dati delle schede allenamento
///   (`allenamenti`, `allenamenti_esercizi`). Solo tabelle: nessun
///   DAO/repository/UI applicativo (arrivano con la Milestone 4.2).
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
    AllenamentiTable,
    AllenamentiEserciziTable,
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
  int get schemaVersion => 3;

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

        // Da schema 1 il catalogo esercizi (schema 2) e le schede
        // allenamento (schema 3) sono entrambi nuovi per questo
        // dispositivo: createTable() usa CREATE TABLE IF NOT EXISTS, quindi
        // è sicuro crearli tutti in un solo passaggio.
        await m.createAll();
      } else if (from < 3) {
        // Da schema 2 il catalogo esercizi esiste già: un createAll()
        // indiscriminato fallirebbe, perché Migrator.createIndex() (a
        // differenza di createTable()) non genera "IF NOT EXISTS" e
        // tenterebbe di ricreare gli indici del catalogo già presenti. Si
        // creano quindi solo le tabelle/indici nuovi di questa versione.
        await m.createTable(allenamentiTable);
        await m.createTable(allenamentiEserciziTable);
        await m.createIndex(idxAllenamentiIdProfilo);
        await m.createIndex(idxAllenamentiAttivo);
        await m.createIndex(idxAllenamentiEserciziIdAllenamento);
        await m.createIndex(idxAllenamentiEserciziIdEsercizio);
      }
    },
    beforeOpen: (details) async {
      // SQLite non abilita l'enforcement delle FK di default (va
      // impostato a ogni apertura di connessione, non persiste nel file
      // DB). Necessario da questa milestone perché
      // allenamenti_esercizi.idAllenamento dichiara ON DELETE CASCADE.
      // Eseguito dopo le eventuali migration (mai durante), per non
      // intralciarle con vincoli attivi su tabelle in fase di modifica.
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  static QueryExecutor _openConnection() {
    return driftDatabase(name: AppConstants.databaseName);
  }
}
