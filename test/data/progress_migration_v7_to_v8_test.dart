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
import 'package:forge/data/database/tables/pressure_measurements_table.dart';
import 'package:forge/data/database/tables/progressioni_esercizi_table.dart';
import 'package:forge/data/database/tables/sessioni_allenamento_table.dart';
import 'package:forge/data/database/tables/sessioni_esercizi_table.dart';
import 'package:forge/data/database/tables/user_equipment_table.dart';
import 'package:forge/data/database/tables/user_profiles_table.dart';
import 'package:forge/data/database/tables/versioni_catalogo_table.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite3;

part 'progress_migration_v7_to_v8_test.g.dart';

/// Forma di `misurazioni_corporee` a schema 7 (Milestone 7.1): `weight_kg`
/// ancora NOT NULL, con l'indice (profileId, measuredAt) già presente —
/// esattamente lo stato prima della Milestone 7.2.
@TableIndex(
  name: 'idx_misurazioni_corporee_profilo_data',
  columns: {#profileId, #measuredAt},
)
class BodyMeasurementsTableV7 extends Table {
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

@DriftDatabase(
  tables: [
    AppSettingsTable,
    UserProfilesTable,
    BodyMeasurementsTableV7,
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
)
class _SchemaV7Database extends _$_SchemaV7Database {
  _SchemaV7Database(super.executor);

  @override
  int get schemaVersion => 7;
}

/// Hardening (Milestone 7.2, sezione 59): verifica che l'upgrade reale
/// 7 -> 8 (ricreazione non distruttiva di `misurazioni_corporee` per
/// rendere `weight_kg` nullable) preservi tutte le righe legacy, mantenga
/// l'indice e la FK, e — soprattutto — sblocchi davvero l'inserimento di
/// misurazioni "solo girovita" prima strutturalmente impossibili.
void main() {
  test('upgrade reale da schema 7 a 8 preserva le misurazioni corporee e '
      'abilita le misurazioni "solo girovita"', () async {
    final schemaV7 = _SchemaV7Database(NativeDatabase.memory());
    await schemaV7.customSelect('SELECT 1').getSingle();
    final ddlRows = await schemaV7
        .customSelect(
          "SELECT sql FROM sqlite_master WHERE type IN ('table', 'index') "
          "AND sql IS NOT NULL AND name NOT LIKE 'sqlite_%'",
        )
        .get();
    final ddl = ddlRows.map((row) => row.read<String>('sql')).toList();
    await schemaV7.close();

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
    rawDb.execute('PRAGMA user_version = 7');

    final database = AppDatabase(NativeDatabase.opened(rawDb));
    addTearDown(database.close);

    expect(database.schemaVersion, 11);

    // Riga legacy preservata integralmente.
    final legacy = await database.bodyMeasurementsDao.getById(1);
    expect(legacy, isNotNull);
    expect(legacy!.weightKg, 79.5);
    expect(legacy.waistCm, 88.0);
    expect(legacy.notes, 'legacy');

    // Altre tabelle non toccate dalla ricreazione.
    final legacyPressure = await database.pressureMeasurementsDao.getById(1);
    expect(legacyPressure, isNotNull);
    expect(legacyPressure!.systolic, 120);

    // L'indice è stato ricreato (perso implicitamente insieme alla
    // vecchia tabella quando viene eliminata).
    final indexRows = await database
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'index' "
          "AND name = 'idx_misurazioni_corporee_profilo_data'",
        )
        .get();
    expect(indexRows, hasLength(1));

    // Il vero obiettivo della migration: una misurazione "solo girovita"
    // (weightKg null) ora è persistibile, cosa strutturalmente impossibile
    // prima di schema 8 (weight_kg era NOT NULL).
    final waistOnlyId = await database.bodyMeasurementsDao.insertMeasurement(
      BodyMeasurementsTableCompanion.insert(
        profileId: 1,
        measuredAt: DateTime(2026, 1, 2, 8),
        waistCm: const Value(90.0),
      ),
    );
    final waistOnly = await database.bodyMeasurementsDao.getById(waistOnlyId);
    expect(waistOnly!.weightKg, isNull);
    expect(waistOnly.waistCm, 90.0);

    // Una misurazione "solo peso" resta ovviamente possibile.
    final weightOnlyId = await database.bodyMeasurementsDao.insertMeasurement(
      BodyMeasurementsTableCompanion.insert(
        profileId: 1,
        measuredAt: DateTime(2026, 1, 3, 8),
        weightKg: const Value(78.0),
      ),
    );
    expect(
      (await database.bodyMeasurementsDao.getById(weightOnlyId))!.weightKg,
      78.0,
    );

    // FK ancora rispettata dopo la ricreazione della tabella.
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
    expect(byProfile, hasLength(3));
  });
}
