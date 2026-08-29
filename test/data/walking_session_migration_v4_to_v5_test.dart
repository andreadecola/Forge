import 'package:drift/drift.dart' hide isNotNull;
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

part 'walking_session_migration_v4_to_v5_test.g.dart';

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
    SessioniAllenamentoTable,
    SessioniEserciziTable,
  ],
)
class _SchemaV4Database extends _$_SchemaV4Database {
  _SchemaV4Database(super.executor);

  @override
  int get schemaVersion => 4;
}

void main() {
  test(
    'upgrade reale da schema 4 a 5 preserva dati e abilita camminate',
    () async {
      final schemaV4 = _SchemaV4Database(NativeDatabase.memory());
      await schemaV4.customSelect('SELECT 1').getSingle();
      final ddlRows = await schemaV4
          .customSelect(
            "SELECT sql FROM sqlite_master WHERE type IN ('table', 'index') "
            "AND sql IS NOT NULL AND name NOT LIKE 'sqlite_%'",
          )
          .get();
      final ddl = ddlRows.map((row) => row.read<String>('sql')).toList();
      await schemaV4.close();

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
        '''INSERT INTO sessioni_allenamento
         (id, id_profilo, nome_allenamento_snapshot, stato, data_inizio,
          data_creazione, data_modifica)
         VALUES (1, 1, 'Sessione precedente', 'COMPLETED', ?, ?, ?)''',
        [now, now, now],
      );
      rawDb.execute('PRAGMA user_version = 4');

      final database = AppDatabase(NativeDatabase.opened(rawDb));
      addTearDown(database.close);

      expect(database.schemaVersion, 8);
      expect((await database.userProfileDao.getCurrentProfile())!.name, 'Alex');
      expect(await database.sessioniAllenamentoDao.getById(1), isNotNull);
      expect(await database.select(database.camminateTable).get(), isEmpty);

      final id = await database
          .into(database.camminateTable)
          .insert(
            CamminateTableCompanion.insert(
              idProfilo: 1,
              dataInizio: DateTime(2026, 1, 1, 11),
              stato: 'IN_PROGRESS',
              dataCreazione: DateTime(2026, 1, 1, 11),
              dataModifica: DateTime(2026, 1, 1, 11),
            ),
          );
      expect((await database.camminateDao.getById(id))!.idProfilo, 1);
      expect(
        () => database
            .into(database.camminateTable)
            .insert(
              CamminateTableCompanion.insert(
                idProfilo: 999,
                dataInizio: DateTime(2026, 1, 1, 12),
                stato: 'COMPLETED',
                dataFine: Value(DateTime(2026, 1, 1, 12, 1)),
                dataCreazione: DateTime(2026, 1, 1, 12),
                dataModifica: DateTime(2026, 1, 1, 12),
              ),
            ),
        throwsA(anything),
      );
    },
  );
}
