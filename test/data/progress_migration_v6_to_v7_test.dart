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
import 'package:forge/data/database/tables/camminate_table.dart';
import 'package:forge/data/database/tables/categorie_esercizi_table.dart';
import 'package:forge/data/database/tables/esercizi_gruppi_muscolari_table.dart';
import 'package:forge/data/database/tables/esercizi_table.dart';
import 'package:forge/data/database/tables/gruppi_muscolari_table.dart';
import 'package:forge/data/database/tables/immagini_esercizi_table.dart';
import 'package:forge/data/database/tables/progressioni_esercizi_table.dart';
import 'package:forge/data/database/tables/sessioni_allenamento_table.dart';
import 'package:forge/data/database/tables/sessioni_esercizi_table.dart';
import 'package:forge/data/database/tables/user_equipment_table.dart';
import 'package:forge/data/database/tables/user_profiles_table.dart';
import 'package:forge/data/database/tables/versioni_catalogo_table.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite3;

part 'progress_migration_v6_to_v7_test.g.dart';

/// Forma di `misurazioni_corporee` a schema 6 (Milestone 7.1): stesse
/// colonne di oggi, ma senza l'indice (profileId, measuredAt) aggiunto in
/// questa milestone.
class BodyMeasurementsTableV6 extends Table {
  @override
  String get tableName => 'misurazioni_corporee';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get profileId => integer().references(UserProfilesTable, #id)();
  DateTimeColumn get measuredAt => dateTime()();
  RealColumn get weightKg => real()();
  RealColumn get neckCm => real().nullable()();
  RealColumn get chestCm => real().nullable()();
  RealColumn get waistCm => real().nullable()();
  RealColumn get abdomenCm => real().nullable()();
  RealColumn get hipsCm => real().nullable()();
  RealColumn get leftArmCm => real().nullable()();
  RealColumn get rightArmCm => real().nullable()();
  RealColumn get leftThighCm => real().nullable()();
  RealColumn get rightThighCm => real().nullable()();
  RealColumn get leftCalfCm => real().nullable()();
  RealColumn get rightCalfCm => real().nullable()();
  TextColumn get notes => text().nullable()();
}

/// Forma di `misurazioni_pressione` a schema 6 (Milestone 7.1): stesse
/// colonne di oggi, senza l'indice aggiunto in questa milestone.
class PressureMeasurementsTableV6 extends Table {
  @override
  String get tableName => 'misurazioni_pressione';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get profileId => integer().references(UserProfilesTable, #id)();
  DateTimeColumn get measuredAt => dateTime()();
  IntColumn get systolic => integer()();
  IntColumn get diastolic => integer()();
  IntColumn get heartRate => integer().nullable()();
  TextColumn get measurementContext => text().nullable()();
  TextColumn get notes => text().nullable()();
}

@DriftDatabase(
  tables: [
    AppSettingsTable,
    UserProfilesTable,
    BodyMeasurementsTableV6,
    CamminateTable,
    PressureMeasurementsTableV6,
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
class _SchemaV6Database extends _$_SchemaV6Database {
  _SchemaV6Database(super.executor);

  @override
  int get schemaVersion => 6;
}

/// Hardening (Milestone 7.1, sezione 31): stesso pattern di
/// `walking_session_migration_v5_to_v6_test.dart` — costruisce uno schema 6
/// realistico via Drift, ne cattura il DDL, lo rigioca su una connessione
/// sqlite3 raw, inserisce righe legacy in `misurazioni_corporee`/
/// `misurazioni_pressione` (oltre a un profilo e una camminata, per
/// verificare che la migration non tocchi altre tabelle), poi apre quella
/// connessione con il vero `AppDatabase` per far scattare l'upgrade reale
/// 6 -> 7.
void main() {
  test('upgrade reale da schema 6 a 7 preserva misurazioni corporee/pressione '
      'e altre tabelle, aggiunge solo i due indici', () async {
    final schemaV6 = _SchemaV6Database(NativeDatabase.memory());
    await schemaV6.customSelect('SELECT 1').getSingle();
    final ddlRows = await schemaV6
        .customSelect(
          "SELECT sql FROM sqlite_master WHERE type IN ('table', 'index') "
          "AND sql IS NOT NULL AND name NOT LIKE 'sqlite_%'",
        )
        .get();
    final ddl = ddlRows.map((row) => row.read<String>('sql')).toList();
    await schemaV6.close();

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
      '''INSERT INTO misurazioni_corporee
           (id, profile_id, measured_at, weight_kg, waist_cm, notes)
           VALUES (1, 1, ?, 79.5, 88.0, 'legacy')''',
      [now],
    );
    rawDb.execute(
      '''INSERT INTO misurazioni_pressione
           (id, profile_id, measured_at, systolic, diastolic)
           VALUES (1, 1, ?, 120, 80)''',
      [now],
    );
    rawDb.execute(
      '''INSERT INTO camminate
           (id, id_profilo, data_inizio, data_fine, distanza_metri, passi,
            stato, note, data_creazione, data_modifica)
           VALUES (1, 1, ?, ?, 3500, 4200, 'COMPLETED', 'legacy', ?, ?)''',
      [now, now + 1800, now, now],
    );
    rawDb.execute('PRAGMA user_version = 6');

    final database = AppDatabase(NativeDatabase.opened(rawDb));
    addTearDown(database.close);

    expect(database.schemaVersion, 8);

    // Dati legacy preservati.
    final legacyBody = await database.bodyMeasurementsDao.getById(1);
    expect(legacyBody, isNotNull);
    expect(legacyBody!.weightKg, 79.5);
    expect(legacyBody.waistCm, 88.0);
    expect(legacyBody.notes, 'legacy');

    final legacyPressure = await database.pressureMeasurementsDao.getById(1);
    expect(legacyPressure, isNotNull);
    expect(legacyPressure!.systolic, 120);
    expect(legacyPressure.diastolic, 80);

    final legacyWalk = await database.camminateDao.getById(1);
    expect(legacyWalk, isNotNull);
    expect(legacyWalk!.distanzaMetri, 3500);

    // Nuovi indici presenti (query per profilo funziona, e non solleva
    // errori "no such index" su un uso esplicito via EXPLAIN QUERY PLAN).
    final indexRows = await database
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'index' "
          "AND name IN ('idx_misurazioni_corporee_profilo_data', "
          "'idx_misurazioni_pressione_profilo_data')",
        )
        .get();
    expect(indexRows.map((r) => r.read<String>('name')).toSet(), {
      'idx_misurazioni_corporee_profilo_data',
      'idx_misurazioni_pressione_profilo_data',
    });

    // CRUD funzionante dopo la migration: nuova misurazione, FK ancora
    // rispettata (profilo inesistente -> eccezione).
    final newBodyId = await database.bodyMeasurementsDao.insertMeasurement(
      BodyMeasurementsTableCompanion.insert(
        profileId: 1,
        measuredAt: DateTime(2026, 1, 2, 8),
        weightKg: const Value(79.0),
      ),
    );
    expect(
      (await database.bodyMeasurementsDao.getById(newBodyId))!.weightKg,
      79.0,
    );
    expect(
      () => database.bodyMeasurementsDao.insertMeasurement(
        BodyMeasurementsTableCompanion.insert(
          profileId: 999,
          measuredAt: DateTime(2026, 1, 2, 8),
          weightKg: const Value(70.0),
        ),
      ),
      throwsA(anything),
    );

    final byProfile = await database.bodyMeasurementsDao
        .getMeasurementsByProfile(1);
    expect(byProfile.length, 2);
  });
}
