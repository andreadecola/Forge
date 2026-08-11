import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../../core/constants/app_constants.dart';
import 'daos/allenamenti_dao.dart';
import 'daos/allenamenti_esercizi_dao.dart';
import 'daos/alternative_esercizi_dao.dart';
import 'daos/app_settings_dao.dart';
import 'daos/attrezzature_dao.dart';
import 'daos/body_measurements_dao.dart';
import 'daos/camminate_dao.dart';
import 'daos/categorie_esercizi_dao.dart';
import 'daos/esercizi_dao.dart';
import 'daos/gruppi_muscolari_dao.dart';
import 'daos/immagini_esercizi_dao.dart';
import 'daos/pressure_measurements_dao.dart';
import 'daos/progressioni_esercizi_dao.dart';
import 'daos/sessioni_allenamento_dao.dart';
import 'daos/sessioni_esercizi_dao.dart';
import 'daos/user_equipment_dao.dart';
import 'daos/user_profile_dao.dart';
import 'tables/allenamenti_esercizi_table.dart';
import 'tables/allenamenti_table.dart';
import 'tables/alternative_esercizi_table.dart';
import 'tables/app_settings_table.dart';
import 'tables/attrezzature_esercizi_table.dart';
import 'tables/attrezzature_table.dart';
import 'tables/body_measurements_table.dart';
import 'tables/camminate_table.dart';
import 'tables/categorie_esercizi_table.dart';
import 'tables/esercizi_gruppi_muscolari_table.dart';
import 'tables/esercizi_table.dart';
import 'tables/gruppi_muscolari_table.dart';
import 'tables/immagini_esercizi_table.dart';
import 'tables/pressure_measurements_table.dart';
import 'tables/progressioni_esercizi_table.dart';
import 'tables/sessioni_allenamento_table.dart';
import 'tables/sessioni_esercizi_table.dart';
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
///   (`allenamenti`, `allenamenti_esercizi`).
/// - Milestone 4.2: DAO/repository/dominio per gli allenamenti (nessuna
///   modifica di schema: resta 3).
/// - Milestone 4.4.3 (schema 4): persistenza della sessione di allenamento
///   in corso (`sessioni_allenamento`, `sessioni_esercizi`), per poterla
///   ripristinare dopo la chiusura dell'app (vedi 07_Training_Engine.md).
/// - Milestone 6.3.2 (schema 6): stato e timestamp della pausa persistita
///   della camminata; il tempo attivo resta derivato.
@DriftDatabase(
  tables: [
    AppSettingsTable,
    UserProfilesTable,
    BodyMeasurementsTable,
    CamminateTable,
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
    SessioniAllenamentoTable,
    SessioniEserciziTable,
  ],
  daos: [
    AppSettingsDao,
    UserProfileDao,
    BodyMeasurementsDao,
    CamminateDao,
    PressureMeasurementsDao,
    UserEquipmentDao,
    CategorieEserciziDao,
    GruppiMuscolariDao,
    AttrezzatureDao,
    EserciziDao,
    ImmaginiEserciziDao,
    ProgressioniEserciziDao,
    AlternativeEserciziDao,
    AllenamentiDao,
    AllenamentiEserciziDao,
    SessioniAllenamentoDao,
    SessioniEserciziDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 6;

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

        // Da schema 1 il catalogo esercizi (schema 2), le schede
        // allenamento (schema 3) e le sessioni (schema 4) sono tutti nuovi
        // per questo dispositivo: createTable() usa CREATE TABLE IF NOT
        // EXISTS, quindi è sicuro crearli tutti in un solo passaggio.
        // `return` evita di ripassare anche dai rami seguenti, che
        // useranno `createIndex()` — a differenza di createTable() non
        // idempotente — su indici che createAll() ha già creato qui.
        await m.createAll();
        return;
      }
      if (from < 3) {
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
      if (from < 4) {
        // Stesso motivo del ramo precedente: da schema 3 tutto il resto
        // esiste già, quindi si creano solo le tabelle/indici nuovi di
        // questa versione (sessione di allenamento persistita, Milestone
        // 4.4.3). Questo ramo viene raggiunto sia da un dispositivo già a
        // schema 3, sia da uno appena passato da schema 2 a 3 dal ramo
        // precedente (nessun `return` lì: from<4 resta vero).
        await m.createTable(sessioniAllenamentoTable);
        await m.createTable(sessioniEserciziTable);
        await m.createIndex(idxSessioniAllenamentoIdAllenamento);
        await m.createIndex(idxSessioniAllenamentoIdProfilo);
        await m.createIndex(idxSessioniAllenamentoStato);
        await m.createIndex(idxSessioniEserciziIdSessione);
        await m.createIndex(idxSessioniEserciziIdAllenamentoEsercizio);
      }
      if (from < 5) {
        // Da schema 4 la nuova tabella è isolata: si crea esplicitamente
        // tabella e indici, evitando createAll() che ricreerebbe gli indici
        // già presenti. L'indice UNIQUE parziale garantisce inoltre una sola
        // camminata IN_PROGRESS per profilo anche in caso di concorrenza.
        await m.createTable(camminateTable);
        await m.createIndex(idxCamminateIdProfiloDataInizio);
        await m.createIndex(idxCamminateAttivaPerProfilo);
      }
      if (from >= 5 && from < 6) {
        await m.addColumn(camminateTable, camminateTable.pausaInCorso);
        await m.addColumn(camminateTable, camminateTable.dataInizioPausa);
        await m.addColumn(camminateTable, camminateTable.durataPausaSecondi);
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
