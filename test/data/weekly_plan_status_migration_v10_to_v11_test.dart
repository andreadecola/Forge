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

part 'weekly_plan_status_migration_v10_to_v11_test.g.dart';

/// Forma di `attivita_pianificate` a schema 10 (Milestone 8.5), PRIMA
/// dell'allargamento del CHECK su `stato` in Milestone 8.6: stesse colonne
/// della tabella corrente (incluso il collegamento sessione di M8.5), ma
/// `stato` ammette solo `PLANNED`.
@TableIndex(
  name: 'idx_attivita_pianificate_profilo_data',
  columns: {#idProfilo, #dataPianificata},
)
class AttivitaPianificateTableV10 extends Table {
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
  IntColumn get idSessioneAllenamento => integer().nullable().references(
    SessioniAllenamentoTable,
    #id,
    onDelete: KeyAction.setNull,
  )();
  IntColumn get idSessioneCamminata => integer().nullable().references(
    CamminateTable,
    #id,
    onDelete: KeyAction.setNull,
  )();

  @override
  List<String> get customConstraints => [
    "CHECK (tipo IN ('WORKOUT', 'WALK', 'RECOVERY'))",
    "CHECK (stato IN ('PLANNED'))",
    "CHECK (origine IN ('USER', 'FORGE_ENGINE'))",
    'CHECK (durata_pianificata_minuti IS NULL OR durata_pianificata_minuti > 0)',
  ];
}

/// Schema 10 realistico (fine Milestone 8.5): tutte le tabelle correnti più
/// `attivita_pianificate` nella sua forma storica (CHECK ristretto).
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
    AttivitaPianificateTableV10,
  ],
)
class _SchemaV10Database extends _$_SchemaV10Database {
  _SchemaV10Database(super.executor);

  @override
  int get schemaVersion => 10;
}

/// Salta/rinvia/ripristina (Milestone 8.6, sezione 20/96): verifica che
/// l'upgrade reale 10 -> 11 (CHECK allargato tramite
/// `Migrator.alterTable`/`TableMigration`, l'unico modo per allargare un
/// CHECK esistente in SQLite) preservi integralmente `attivita_pianificate`
/// esistente — righe, FK, indice — e accetti i nuovi valori di stato.
void main() {
  test('upgrade reale da schema 10 a 11 preserva attivita_pianificate '
      'esistenti (comprese le colonne sessione di M8.5) e allarga il CHECK '
      'su stato a SKIPPED/POSTPONED', () async {
    final schemaV10 = _SchemaV10Database(NativeDatabase.memory());
    await schemaV10.customSelect('SELECT 1').getSingle();
    final ddlRows = await schemaV10
        .customSelect(
          "SELECT sql FROM sqlite_master WHERE type IN ('table', 'index') "
          "AND sql IS NOT NULL AND name NOT LIKE 'sqlite_%'",
        )
        .get();
    final ddl = ddlRows.map((row) => row.read<String>('sql')).toList();
    await schemaV10.close();

    final rawDb = sqlite3.sqlite3.openInMemory();
    for (final statement in ddl) {
      rawDb.execute(statement);
    }
    final now = DateTime(2026, 1, 1, 10).millisecondsSinceEpoch ~/ 1000;
    final scheduledDate = DateTime(2026, 1, 1).millisecondsSinceEpoch ~/ 1000;
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
      '''INSERT INTO sessioni_allenamento
             (id, id_profilo, id_allenamento, nome_allenamento_snapshot,
              stato, data_inizio, data_creazione, data_modifica)
             VALUES (1, 1, 1, 'Scheda gambe', 'ABORTED', ?, ?, ?)''',
      [now, now, now],
    );
    rawDb.execute(
      '''INSERT INTO attivita_pianificate
             (id, id_profilo, data_pianificata, tipo, id_allenamento,
              id_sessione_allenamento, stato, origine, data_creazione,
              data_modifica)
             VALUES (1, 1, ?, 'WORKOUT', 1, 1, 'PLANNED', 'USER', ?, ?)''',
      [scheduledDate, now, now],
    );
    rawDb.execute('PRAGMA user_version = 10');

    final database = AppDatabase(NativeDatabase.opened(rawDb));
    addTearDown(database.close);

    expect(database.schemaVersion, 11);

    // La riga legacy resta intatta, incluso il collegamento sessione già
    // presente da M8.5.
    final legacyActivity = await database.attivitaPianificateDao.getById(1);
    expect(legacyActivity, isNotNull);
    expect(legacyActivity!.stato, 'PLANNED');
    expect(legacyActivity.idSessioneAllenamento, 1);

    // Il nuovo CHECK accetta SKIPPED/POSTPONED.
    await database.attivitaPianificateDao.updateActivity(
      AttivitaPianificateTableCompanion(
        id: const Value(1),
        idProfilo: const Value(1),
        dataPianificata: Value(legacyActivity.dataPianificata),
        tipo: const Value('WORKOUT'),
        idAllenamento: const Value(1),
        idSessioneAllenamento: const Value(1),
        stato: const Value('SKIPPED'),
        origine: const Value('USER'),
        dataCreazione: Value(legacyActivity.dataCreazione),
        dataModifica: Value(DateTime(2026, 1, 5)),
      ),
    );
    final skipped = await database.attivitaPianificateDao.getById(1);
    expect(skipped!.stato, 'SKIPPED');

    // Un valore ancora fuori dal CHECK resta rifiutato.
    expect(
      () => database.customStatement(
        "UPDATE attivita_pianificate SET stato = 'DONE' WHERE id = 1",
      ),
      throwsA(anything),
    );

    // FK ancora rispettata dopo la ricreazione tabella: profilo
    // inesistente rifiutato su una nuova riga.
    expect(
      () => database.attivitaPianificateDao.create(
        AttivitaPianificateTableCompanion.insert(
          idProfilo: 999999,
          dataPianificata: DateTime(2026, 1, 6),
          tipo: 'RECOVERY',
          origine: 'USER',
          dataCreazione: DateTime(2026, 1, 6),
          dataModifica: DateTime(2026, 1, 6),
        ),
      ),
      throwsA(anything),
    );

    // L'indice (profilo, data) sopravvive alla ricreazione tabella: una
    // query per settimana resta efficiente e corretta.
    final forWeek = await database.attivitaPianificateDao.getForWeek(
      profileId: 1,
      weekStart: DateTime(2026, 1, 1),
      weekEnd: DateTime(2026, 1, 1),
    );
    expect(forWeek, hasLength(1));

    final indexRow = await database
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'index' AND "
          "name = 'idx_attivita_pianificate_profilo_data'",
        )
        .get();
    expect(indexRow, hasLength(1));
  });
}
