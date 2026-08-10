import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/data/database/app_database.dart';
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
import 'package:forge/data/database/tables/user_equipment_table.dart';
import 'package:forge/data/database/tables/user_profiles_table.dart';
import 'package:forge/data/database/tables/versioni_catalogo_table.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite3;

part 'workout_migration_v2_to_v3_test.g.dart';

/// Riproduce esattamente lo schema 2 (Milestone 3.1: tabelle M2 già
/// rinominate in italiano + struttura catalogo esercizi, senza le tabelle
/// allenamenti/allenamenti_esercizi della Milestone 4.1). Serve solo a
/// generare via `sqlite_master` il DDL reale dello schema 2, evitando di
/// riscriverlo a mano (rischio di refusi rispetto alle classi Table vere).
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
)
class _SchemaV2Database extends _$_SchemaV2Database {
  _SchemaV2Database(super.executor);

  @override
  int get schemaVersion => 2;
}

/// Simula un dispositivo reale già a schema 2 (Milestone 3.1) e verifica
/// che l'upgrade a schema 3 (Milestone 4.1):
/// - preservi tutti i dati M2 e del catalogo esercizi già presenti;
/// - crei solo `allenamenti`/`allenamenti_esercizi`, senza toccare altro.
void main() {
  test('upgrade da schema 2 a schema 3 preserva i dati esistenti e crea le '
      'tabelle allenamenti', () async {
    // 1. Genera il DDL reale dello schema 2 da una istanza temporanea,
    // così da non doverlo trascrivere a mano.
    final schemaV2Db = _SchemaV2Database(NativeDatabase.memory());
    await schemaV2Db.customSelect('SELECT 1').getSingle();
    final ddlRows = await schemaV2Db
        .customSelect(
          "SELECT sql FROM sqlite_master "
          "WHERE type IN ('table', 'index') AND sql IS NOT NULL "
          "AND name NOT LIKE 'sqlite_%'",
        )
        .get();
    final schemaV2Ddl = ddlRows.map((r) => r.read<String>('sql')).toList();
    await schemaV2Db.close();

    // 2. Applica quel DDL a un database "reale" indipendente e popolalo
    // con dati realistici, come farebbe un dispositivo già in uso.
    final rawDb = sqlite3.sqlite3.openInMemory();
    for (final statement in schemaV2Ddl) {
      rawDb.execute(statement);
    }

    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    rawDb.execute(
      '''
        INSERT INTO profili_utente
          (id, name, birth_date, height_cm, initial_weight_kg,
           preferred_walk_minutes, equipment_budget_limit, start_date,
           created_at, updated_at)
        VALUES (1, 'Alex', ?, 175, 80, 30, 50, ?, ?, ?);
        ''',
      [now, now, now, now],
    );
    rawDb.execute(
      '''
        INSERT INTO misurazioni_corporee (profile_id, measured_at, weight_kg)
        VALUES (1, ?, 78.5);
        ''',
      [now],
    );
    rawDb.execute(
      '''
        INSERT INTO misurazioni_pressione
          (profile_id, measured_at, systolic, diastolic)
        VALUES (1, ?, 120, 80);
        ''',
      [now],
    );
    rawDb.execute('''
        INSERT INTO attrezzature_utente (profile_id, equipment_code, owned)
        VALUES (1, 'chair', 1);
      ''');
    rawDb.execute(
      '''
        INSERT INTO categorie_esercizi
          (id, codice, nome, data_creazione, data_modifica)
        VALUES (1, 'MOBILITA', 'Mobilità', ?, ?);
        ''',
      [now, now],
    );
    rawDb.execute(
      '''
        INSERT INTO esercizi
          (id, codice, nome, descrizione, istruzioni, id_categoria,
           livello_minimo, livello_impatto, versione_catalogo,
           data_creazione, data_modifica)
        VALUES
          (1, 'MOB-001', 'Respirazione diaframmatica', 'Descrizione',
           'Istruzioni', 1, 1, 'VERY_LOW', 1, ?, ?);
        ''',
      [now, now],
    );
    rawDb.execute(
      '''
        INSERT INTO versioni_catalogo (tipo_catalogo, versione, data_importazione)
        VALUES ('ESERCIZI', 1, ?);
        ''',
      [now],
    );

    // Segna il database come "già a schema 2": scatena onUpgrade(2, 3)
    // all'apertura, esattamente come su un dispositivo reale.
    rawDb.execute('PRAGMA user_version = 2;');

    final database = AppDatabase(NativeDatabase.opened(rawDb));
    addTearDown(database.close);

    // 3. Verifica: dati M2 preservati.
    final profile = await database.userProfileDao.getCurrentProfile();
    expect(profile, isNotNull);
    expect(profile!.name, 'Alex');

    final measurements = await database.bodyMeasurementsDao
        .getMeasurementsByProfile(profile.id);
    expect(measurements, hasLength(1));
    expect(measurements.single.weightKg, 78.5);

    final pressure = await database.pressureMeasurementsDao.getLatestPressure(
      profile.id,
    );
    expect(pressure, isNotNull);
    expect(pressure!.systolic, 120);

    final equipment = await database.userEquipmentDao.getOwnedEquipment(
      profile.id,
    );
    expect(equipment.map((e) => e.equipmentCode), contains('chair'));

    // Catalogo e versione catalogo preservati.
    final categorie = await database
        .select(database.categorieEserciziTable)
        .get();
    expect(categorie, hasLength(1));
    expect(categorie.single.codice, 'MOBILITA');

    final esercizi = await database.select(database.eserciziTable).get();
    expect(esercizi, hasLength(1));
    expect(esercizi.single.codice, 'MOB-001');

    final versioni = await database
        .select(database.versioniCatalogoTable)
        .get();
    expect(versioni, hasLength(1));
    expect(versioni.single.tipoCatalogo, 'ESERCIZI');

    // 4. Le nuove tabelle della Milestone 4.1 devono essere disponibili
    // e vuote (nessun seed allenamenti in questa milestone). La versione
    // finale è quella corrente (4, Milestone 4.4.3): un dispositivo reale
    // a schema 2 arriva sempre all'ultimo schema, non si ferma a metà.
    expect(database.schemaVersion, 4);
    expect(await database.select(database.allenamentiTable).get(), isEmpty);
    expect(
      await database.select(database.allenamentiEserciziTable).get(),
      isEmpty,
    );

    // 5. La nuova struttura funziona davvero sul database migrato (non
    // solo "esiste"): un allenamento può essere inserito e collegato al
    // profilo e all'esercizio preservati dalla migrazione.
    final idAllenamento = await database
        .into(database.allenamentiTable)
        .insert(
          AllenamentiTableCompanion.insert(
            idProfilo: profile.id,
            nome: 'Scheda post-migrazione',
            tipoAllenamento: 'FULL_BODY',
            stato: 'DRAFT',
            origine: 'USER',
            dataCreazione: DateTime.now(),
            dataModifica: DateTime.now(),
          ),
        );
    await database
        .into(database.allenamentiEserciziTable)
        .insert(
          AllenamentiEserciziTableCompanion.insert(
            idAllenamento: idAllenamento,
            idEsercizio: esercizi.single.id,
            ordine: 1,
            dataCreazione: DateTime.now(),
            dataModifica: DateTime.now(),
          ),
        );
    expect(
      await database.select(database.allenamentiEserciziTable).get(),
      hasLength(1),
    );
  });
}
