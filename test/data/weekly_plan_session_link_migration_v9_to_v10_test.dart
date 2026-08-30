import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/data/database/app_database.dart';
import 'package:forge/data/database/tables/allenamenti_esercizi_table.dart';
import 'package:forge/data/database/tables/allenamenti_table.dart';
import 'package:forge/data/database/tables/alternative_esercizi_table.dart';
import 'package:forge/data/database/tables/app_settings_table.dart';
import 'package:forge/data/database/tables/attrezzature_esercizi_table.dart';
import 'package:forge/data/database/tables/attrezzature_table.dart';
import 'package:forge/data/database/tables/body_measurements_table.dart';
import 'package:forge/data/database/tables/camminate_table.dart';
import 'package:forge/data/database/tables/categorie_esercizi_table.dart';
import 'package:forge/data/database/tables/esercizi_gruppi_muscolari_table.dart';
import 'package:forge/data/database/tables/esercizi_table.dart';
import 'package:forge/data/database/tables/gruppi_muscolari_table.dart';
import 'package:forge/data/database/tables/immagini_esercizi_table.dart';
import 'package:forge/data/database/tables/pressure_measurements_table.dart';
import 'package:forge/data/database/tables/progressioni_esercizi_table.dart';
import 'package:forge/data/database/tables/sessioni_allenamento_table.dart';
import 'package:forge/data/database/tables/sessioni_esercizi_table.dart';
import 'package:forge/data/database/tables/user_equipment_table.dart';
import 'package:forge/data/database/tables/user_profiles_table.dart';
import 'package:forge/data/database/tables/versioni_catalogo_table.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite3;

part 'weekly_plan_session_link_migration_v9_to_v10_test.g.dart';

/// Forma di `attivita_pianificate` a schema 9 (Milestone 8.1), PRIMA delle
/// due colonne di collegamento sessione aggiunte in Milestone 8.5: una
/// copia locale, non la classe Dart corrente (che le ha già) — stesso
/// principio già seguito per `misurazioni_corporee` in M7.2.
@TableIndex(
  name: 'idx_attivita_pianificate_profilo_data',
  columns: {#idProfilo, #dataPianificata},
)
class AttivitaPianificateTableV9 extends Table {
  @override
  String get tableName => 'attivita_pianificate';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get idProfilo => integer().references(UserProfilesTable, #id)();
  DateTimeColumn get dataPianificata => dateTime()();
  TextColumn get tipo => text()();
  IntColumn get idAllenamento => integer().nullable().references(
    AllenamentiTable,
    #id,
    onDelete: KeyAction.setNull,
  )();
  IntColumn get durataPianificataMinuti => integer().nullable()();
  TextColumn get stato => text().withDefault(const Constant('PLANNED'))();
  TextColumn get origine => text()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get dataCreazione => dateTime()();
  DateTimeColumn get dataModifica => dateTime()();

  @override
  List<String> get customConstraints => [
    "CHECK (tipo IN ('WORKOUT', 'WALK', 'RECOVERY'))",
    "CHECK (stato IN ('PLANNED'))",
    "CHECK (origine IN ('USER', 'FORGE_ENGINE'))",
    'CHECK (durata_pianificata_minuti IS NULL OR durata_pianificata_minuti > 0)',
  ];
}

/// Schema 9 realistico (fine Milestone 8.1): tutte le tabelle correnti più
/// `attivita_pianificate` nella sua forma storica (senza le colonne di
/// collegamento sessione).
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
    AttivitaPianificateTableV9,
  ],
)
class _SchemaV9Database extends _$_SchemaV9Database {
  _SchemaV9Database(super.executor);

  @override
  int get schemaVersion => 9;
}

/// Collegamento esplicito piano -> sessione reale (Milestone 8.5, sezione
/// 49/50/83): verifica che l'upgrade reale 9 -> 10 (due colonne additive)
/// preservi integralmente `attivita_pianificate` esistente e aggiunga solo
/// le due colonne nullable — nessuna tabella ricreata, nessun dato perso.
void main() {
  test(
    'upgrade reale da schema 9 a 10 preserva attivita_pianificate '
    'esistenti e aggiunge id_sessione_allenamento/id_sessione_camminata',
    () async {
      final schemaV9 = _SchemaV9Database(NativeDatabase.memory());
      await schemaV9.customSelect('SELECT 1').getSingle();
      final ddlRows = await schemaV9
          .customSelect(
            "SELECT sql FROM sqlite_master WHERE type IN ('table', 'index') "
            "AND sql IS NOT NULL AND name NOT LIKE 'sqlite_%'",
          )
          .get();
      final ddl = ddlRows.map((row) => row.read<String>('sql')).toList();
      await schemaV9.close();

      final rawDb = sqlite3.sqlite3.openInMemory();
      for (final statement in ddl) {
        rawDb.execute(statement);
      }
      final now = DateTime(2026, 1, 1, 10).millisecondsSinceEpoch ~/ 1000;
      rawDb.execute(
        '''INSERT INTO profili_utente
             (id, name, birth_date, height_cm, initial_weight_kg,
              preferred_walk_minutes, equipment_budget_limit, start_date,
              created_at, updated_at)
             VALUES (1, 'Alex', ?, 175, 80, 30, 50, ?, ?, ?)''',
        [now, now, now, now],
      );
      rawDb.execute(
        '''INSERT INTO allenamenti
             (id, id_profilo, nome, tipo_allenamento, livello, stato, origine,
              attivo, data_creazione, data_modifica)
             VALUES (1, 1, 'Scheda gambe', 'LOWER_BODY', 1, 'READY', 'USER', 1, ?, ?)''',
        [now, now],
      );
      rawDb.execute(
        '''INSERT INTO attivita_pianificate
             (id, id_profilo, data_pianificata, tipo, id_allenamento, stato,
              origine, data_creazione, data_modifica)
             VALUES (1, 1, ?, 'WORKOUT', 1, 'PLANNED', 'USER', ?, ?)''',
        [now, now, now],
      );
      rawDb.execute('PRAGMA user_version = 9');

      final database = AppDatabase(NativeDatabase.opened(rawDb));
      addTearDown(database.close);

      expect(database.schemaVersion, 11);

      // L'attività pianificata legacy resta intatta, entrambe le nuove
      // colonne sono NULL (mai valorizzate finché non si collega davvero
      // una sessione).
      final legacyActivity = await database.attivitaPianificateDao.getById(1);
      expect(legacyActivity, isNotNull);
      expect(legacyActivity!.tipo, 'WORKOUT');
      expect(legacyActivity.idAllenamento, 1);
      expect(legacyActivity.idSessioneAllenamento, isNull);
      expect(legacyActivity.idSessioneCamminata, isNull);

      // Le nuove colonne sono realmente scrivibili/leggibili. Insert via
      // SQL grezzo (non il Companion generato): questo file dichiara il
      // proprio `@DriftDatabase` locale per la ricostruzione storica, che
      // genera un `SessioniAllenamentoTableCompanion` proprio, in
      // conflitto di nome con quello reale di `AppDatabase` — SQL grezzo
      // evita l'ambiguità.
      await database.customStatement(
        '''INSERT INTO sessioni_allenamento
             (id, id_profilo, id_allenamento, nome_allenamento_snapshot,
              stato, data_inizio, data_creazione, data_modifica)
             VALUES (1, 1, 1, 'Scheda gambe', 'IN_PROGRESS', ?, ?, ?)''',
        [now, now, now],
      );
      const sessionId = 1;
      await database.attivitaPianificateDao.updateActivity(
        AttivitaPianificateTableCompanion(
          id: const Value(1),
          idProfilo: const Value(1),
          dataPianificata: Value(legacyActivity.dataPianificata),
          tipo: const Value('WORKOUT'),
          idAllenamento: const Value(1),
          stato: const Value('PLANNED'),
          origine: const Value('USER'),
          idSessioneAllenamento: const Value(sessionId),
          dataCreazione: Value(legacyActivity.dataCreazione),
          dataModifica: Value(DateTime(2026, 1, 5)),
        ),
      );
      final relinked = await database.attivitaPianificateDao.getById(1);
      expect(relinked!.idSessioneAllenamento, sessionId);

      // FK ancora rispettata sulla nuova colonna: sessione inesistente
      // rifiutata.
      expect(
        () => database.attivitaPianificateDao.updateActivity(
          AttivitaPianificateTableCompanion(
            id: const Value(1),
            idProfilo: const Value(1),
            dataPianificata: Value(legacyActivity.dataPianificata),
            tipo: const Value('WORKOUT'),
            idAllenamento: const Value(1),
            stato: const Value('PLANNED'),
            origine: const Value('USER'),
            idSessioneAllenamento: const Value(999999),
            dataCreazione: Value(legacyActivity.dataCreazione),
            dataModifica: Value(DateTime(2026, 1, 5)),
          ),
        ),
        throwsA(anything),
      );
    },
  );
}
