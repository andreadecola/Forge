import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../../core/constants/app_constants.dart';
import 'daos/allenamenti_dao.dart';
import 'daos/allenamenti_esercizi_dao.dart';
import 'daos/alternative_esercizi_dao.dart';
import 'daos/app_settings_dao.dart';
import 'daos/attivita_pianificate_dao.dart';
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
import 'tables/attivita_pianificate_table.dart';
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
/// - Milestone 7.1 (schema 7): indici su (profileId, measuredAt) per
///   `misurazioni_corporee`/`misurazioni_pressione` — nessuna nuova colonna,
///   nessuna nuova tabella (fondamenta del modulo Progressi, che riusa lo
///   storico peso/girovita/pressione già esistente dalla Milestone 2).
/// - Milestone 7.2 (schema 8): `weight_kg` in `misurazioni_corporee` diventa
///   nullable, per permettere misurazioni "solo girovita" (vedi
///   Docs/M7_2_Weight_Waist.md). Nessuna nuova tabella.
/// - Milestone 8.1 (schema 9): `attivita_pianificate` — fondamenta del
///   Piano Settimanale (vedi Docs/M8_1_Weekly_Plan_Foundations.md). Nessuna
///   modifica alle tabelle esistenti: il piano referenzia `allenamenti` via
///   FK nullable (`ON DELETE SET NULL`), senza toccare `sessioni_allenamento`
///   né `camminate`.
/// - Milestone 8.5 (schema 10): `attivita_pianificate` guadagna
///   `id_sessione_allenamento`/`id_sessione_camminata`, nullable, `ON
///   DELETE SET NULL` verso `sessioni_allenamento`/`camminate` — il
///   collegamento esplicito piano -> sessione reale (vedi
///   Docs/M8_5_Real_Session_Linking.md). Nessuna modifica a
///   `sessioni_allenamento`/`camminate` stesse.
/// - Milestone 8.6 (schema 11): `stato` di `attivita_pianificate` ammette
///   anche `SKIPPED`/`POSTPONED` (CHECK ricreato tramite
///   `Migrator.alterTable`, l'unico modo per allargare un CHECK esistente
///   in SQLite) — spostare/saltare/rinviare un'attività senza perdere il
///   piano (vedi Docs/M8_6_Rescheduling_Skipped_Postponed.md). Nessun
///   nuovo campo, nessun valore `MOVED` (uno spostamento è solo un cambio
///   di `data_pianificata`).
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
    AttivitaPianificateTable,
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
    AttivitaPianificateDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 11;

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
      if (from < 7) {
        // Da schema 6 le due tabelle esistono già senza indice dedicato:
        // solo due indici nuovi, nessuna colonna/tabella (Milestone 7.1,
        // fondamenta del modulo Progressi — vedi Docs/M7_1_Progress_Foundations.md).
        //
        // `IF NOT EXISTS` (invece di `m.createIndex()`, che non lo genera)
        // perché `misurazioni_corporee`/`misurazioni_pressione` sono
        // tabelle Milestone 2 non cambiate da schema 1: i test di
        // migrazione più vecchi (es. schema 2->3, 4->5) ricostruiscono il
        // loro "schema storico" riusando direttamente queste classi Table
        // correnti (non erano ancora cambiate a quel punto), quindi il
        // loro DDL catturato include già questo indice — ricrearlo senza
        // `IF NOT EXISTS` fallirebbe con "index already exists" per quei
        // soli test, pur non essendoci alcun problema su un dispositivo
        // reale. Stesso principio già documentato sopra per
        // `createTable()` vs `createIndex()`.
        await customStatement(
          'CREATE INDEX IF NOT EXISTS '
          'idx_misurazioni_corporee_profilo_data ON misurazioni_corporee '
          '(profile_id, measured_at)',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS '
          'idx_misurazioni_pressione_profilo_data ON misurazioni_pressione '
          '(profile_id, measured_at)',
        );
      }
      if (from < 8) {
        // SQLite non supporta ALTER COLUMN per rendere una colonna NOT
        // NULL -> nullable: si ricrea la tabella preservando i dati
        // (Milestone 7.2 — "solo girovita", vedi
        // Docs/M7_2_Weight_Waist.md). `bodyMeasurementsTable` qui è già la
        // definizione con `weight_kg` nullable, quindi createTable() crea
        // direttamente la nuova forma.
        //
        // L'indice su (profile_id, measured_at) segue implicitamente la
        // tabella nel rename e viene eliminato insieme a
        // `misurazioni_corporee_old`: va ricreato esplicitamente alla
        // fine, con `IF NOT EXISTS` per lo stesso motivo del ramo `from <
        // 7` sopra (test di migrazione più vecchi che riusano la classe
        // Table corrente, già nullable, per ricostruire schemi storici).
        await customStatement(
          'ALTER TABLE misurazioni_corporee '
          'RENAME TO misurazioni_corporee_old',
        );
        await m.createTable(bodyMeasurementsTable);
        await customStatement(
          'INSERT INTO misurazioni_corporee '
          '(id, profile_id, measured_at, weight_kg, neck_cm, chest_cm, '
          'waist_cm, abdomen_cm, hips_cm, left_arm_cm, right_arm_cm, '
          'left_thigh_cm, right_thigh_cm, left_calf_cm, right_calf_cm, '
          'notes) '
          'SELECT id, profile_id, measured_at, weight_kg, neck_cm, '
          'chest_cm, waist_cm, abdomen_cm, hips_cm, left_arm_cm, '
          'right_arm_cm, left_thigh_cm, right_thigh_cm, left_calf_cm, '
          'right_calf_cm, notes '
          'FROM misurazioni_corporee_old',
        );
        await m.deleteTable('misurazioni_corporee_old');
        await customStatement(
          'CREATE INDEX IF NOT EXISTS '
          'idx_misurazioni_corporee_profilo_data ON misurazioni_corporee '
          '(profile_id, measured_at)',
        );
      }
      if (from < 9) {
        // Tabella nuova (Milestone 8.1, fondamenta del Piano Settimanale —
        // vedi Docs/M8_1_Weekly_Plan_Foundations.md): a differenza degli
        // indici su `misurazioni_corporee`/`misurazioni_pressione` nei rami
        // precedenti, qui non c'è alcun rischio di collisione con test di
        // migrazione più vecchi che ricostruiscono schemi storici — questa
        // tabella non esisteva concettualmente prima di schema 9, quindi
        // nessuno di quei test la include mai. `createIndex()` normale
        // (non `IF NOT EXISTS`) è quindi sicuro qui.
        await m.createTable(attivitaPianificateTable);
        await m.createIndex(idxAttivitaPianificateProfiloData);
      }
      if (from >= 9 && from < 10) {
        // Colonne nuove su `attivita_pianificate` (Milestone 8.5,
        // collegamento esplicito piano -> sessione reale). Guardia `from >=
        // 9` (stesso principio già usato per le colonne pausa di
        // `camminate`, ramo schema 5->6 sopra): per un dispositivo che
        // arriva da uno schema precedente a 9, il ramo `from < 9` appena
        // sopra crea `attivita_pianificate` con `m.createTable()`, che
        // riflette sempre la definizione Dart CORRENTE della tabella —
        // quindi le include già entrambe. Senza questa guardia, un
        // `addColumn` su una colonna già appena creata fallirebbe con
        // "duplicate column name" (bug reale, trovato da un test di
        // migrazione storica e corretto qui).
        await m.addColumn(
          attivitaPianificateTable,
          attivitaPianificateTable.idSessioneAllenamento,
        );
        await m.addColumn(
          attivitaPianificateTable,
          attivitaPianificateTable.idSessioneCamminata,
        );
      }
      if (from >= 9 && from < 11) {
        // Il CHECK su `stato` passa da un solo valore (`PLANNED`) a tre
        // (Milestone 8.6: `SKIPPED`/`POSTPONED` aggiunti) — SQLite non
        // supporta un `ALTER TABLE` diretto su un CHECK esistente, quindi
        // si usa la procedura standard di ricreazione tabella (Drift la
        // implementa in `Migrator.alterTable`/`TableMigration`): crea una
        // tabella temporanea con la definizione Dart CORRENTE (CHECK
        // esteso, comprese le colonne sessione di Milestone 8.5), copia
        // tutte le righe esistenti, droppa la vecchia, rinomina — nessuna
        // perdita di dati, indici/FK ricreati automaticamente. Guardia `from
        // >= 9` (stesso principio già usato sopra, schema 9->10): un
        // dispositivo con `from < 9` ha già ricevuto la tabella nella sua
        // forma finale dal `createTable()` sopra (che riflette sempre la
        // classe Dart corrente), quindi non deve rieseguire questa
        // ricreazione. `from < 11` copre sia chi arriva da schema 9 (dopo
        // l'addColumn appena sopra) sia da schema 10.
        await m.alterTable(TableMigration(attivitaPianificateTable));
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

  /// Versione corrente di ciascun catalogo seedato (`tipoCatalogo` →
  /// `versione` massima mai importata), letta da `versioni_catalogo`
  /// (Backup.2, sezione 6): usata solo come metadata diagnostica del
  /// backup, mai per decidere se un backup è importabile (Backup.1,
  /// sezione 7.2). Nessun DAO dedicato: `versioni_catalogo` non ha altri
  /// consumatori applicativi oltre al seeder stesso, che vi scrive
  /// direttamente.
  Future<Map<String, int>> currentCatalogVersions() async {
    final rows = await select(versioniCatalogoTable).get();
    final result = <String, int>{};
    for (final row in rows) {
      final current = result[row.tipoCatalogo];
      if (current == null || row.versione > current) {
        result[row.tipoCatalogo] = row.versione;
      }
    }
    return result;
  }

  static QueryExecutor _openConnection() {
    return driftDatabase(name: AppConstants.databaseName);
  }
}
