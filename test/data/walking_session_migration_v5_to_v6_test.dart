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

part 'walking_session_migration_v5_to_v6_test.g.dart';

@TableIndex(
  name: 'idx_camminate_id_profilo_data_inizio',
  columns: {#idProfilo, #dataInizio},
)
@TableIndex.sql(
  'CREATE UNIQUE INDEX idx_camminate_attiva_per_profilo '
  'ON camminate (id_profilo) WHERE stato = \'IN_PROGRESS\'',
)
class CamminateTableV5 extends Table {
  @override
  String get tableName => 'camminate';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get idProfilo => integer().references(UserProfilesTable, #id)();
  DateTimeColumn get dataInizio => dateTime()();
  DateTimeColumn get dataFine => dateTime().nullable()();
  IntColumn get distanzaMetri => integer().nullable()();
  IntColumn get passi => integer().nullable()();
  TextColumn get stato => text()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get dataCreazione => dateTime()();
  DateTimeColumn get dataModifica => dateTime()();

  @override
  List<String> get customConstraints => [
    'CHECK (distanza_metri IS NULL OR distanza_metri >= 0)',
    'CHECK (passi IS NULL OR passi >= 0)',
    "CHECK (stato IN ('IN_PROGRESS', 'COMPLETED', 'ABORTED'))",
  ];
}

@DriftDatabase(
  tables: [
    AppSettingsTable,
    UserProfilesTable,
    BodyMeasurementsTable,
    CamminateTableV5,
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
)
class _SchemaV5Database extends _$_SchemaV5Database {
  _SchemaV5Database(super.executor);

  @override
  int get schemaVersion => 5;
}

void main() {
  test('upgrade reale da schema 5 a 6 preserva camminate e metriche', () async {
    final schemaV5 = _SchemaV5Database(NativeDatabase.memory());
    await schemaV5.customSelect('SELECT 1').getSingle();
    final ddlRows = await schemaV5
        .customSelect(
          "SELECT sql FROM sqlite_master WHERE type IN ('table', 'index') "
          "AND sql IS NOT NULL AND name NOT LIKE 'sqlite_%'",
        )
        .get();
    final ddl = ddlRows.map((row) => row.read<String>('sql')).toList();
    await schemaV5.close();

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
      '''INSERT INTO camminate
         (id, id_profilo, data_inizio, data_fine, distanza_metri, passi,
          stato, note, data_creazione, data_modifica)
         VALUES (1, 1, ?, ?, 3500, 4200, 'COMPLETED', 'legacy', ?, ?)''',
      [now, now + 1800, now, now],
    );
    rawDb.execute('PRAGMA user_version = 5');

    final database = AppDatabase(NativeDatabase.opened(rawDb));
    addTearDown(database.close);

    expect(database.schemaVersion, 6);
    final legacy = await database.camminateDao.getById(1);
    expect(legacy, isNotNull);
    expect(legacy!.distanzaMetri, 3500);
    expect(legacy.passi, 4200);
    expect(legacy.stato, 'COMPLETED');
    expect(legacy.pausaInCorso, isFalse);
    expect(legacy.dataInizioPausa, isNull);
    expect(legacy.durataPausaSecondi, 0);

    final newId = await database.camminateDao.create(
      CamminateTableCompanion.insert(
        idProfilo: 1,
        dataInizio: DateTime(2026, 1, 1, 11),
        stato: 'IN_PROGRESS',
        dataCreazione: DateTime(2026, 1, 1, 11),
        dataModifica: DateTime(2026, 1, 1, 11),
      ),
    );
    expect((await database.camminateDao.getById(newId))!.idProfilo, 1);
    expect(
      () => database.camminateDao.create(
        CamminateTableCompanion.insert(
          idProfilo: 999,
          dataInizio: DateTime(2026, 1, 1, 12),
          stato: 'COMPLETED',
          dataCreazione: DateTime(2026, 1, 1, 12),
          dataModifica: DateTime(2026, 1, 1, 12),
        ),
      ),
      throwsA(anything),
    );
  });
}
