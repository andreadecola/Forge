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
import 'package:forge/data/database/tables/user_equipment_table.dart';
import 'package:forge/data/database/tables/user_profiles_table.dart';
import 'package:forge/data/database/tables/versioni_catalogo_table.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite3;

part 'workout_session_migration_v3_to_v4_test.g.dart';

/// Riproduce esattamente lo schema 3 (Milestone 4.1/4.2: tabelle
/// allenamenti/allenamenti_esercizi già presenti, ma non ancora le
/// sessioni della Milestone 4.4.3). Stesso scopo di `_SchemaV2Database` in
/// `workout_migration_v2_to_v3_test.dart`.
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
)
class _SchemaV3Database extends _$_SchemaV3Database {
  _SchemaV3Database(super.executor);

  @override
  int get schemaVersion => 3;
}

/// Simula un dispositivo reale già a schema 3 (Milestone 4.2, con almeno
/// una scheda già creata) e verifica che l'upgrade a schema 4 (Milestone
/// 4.4.3):
/// - preservi tutti i dati precedenti (profilo, catalogo, scheda e sua
///   riga);
/// - crei solo `sessioni_allenamento`/`sessioni_esercizi`, senza toccare
///   altro;
/// - la nuova struttura funzioni davvero (una sessione può essere creata e
///   collegata alla scheda/esercizio già esistenti).
void main() {
  test('upgrade da schema 3 a schema 4 preserva i dati esistenti e crea le '
      'tabelle sessione', () async {
    final schemaV3Db = _SchemaV3Database(NativeDatabase.memory());
    await schemaV3Db.customSelect('SELECT 1').getSingle();
    final ddlRows = await schemaV3Db
        .customSelect(
          "SELECT sql FROM sqlite_master "
          "WHERE type IN ('table', 'index') AND sql IS NOT NULL "
          "AND name NOT LIKE 'sqlite_%'",
        )
        .get();
    final schemaV3Ddl = ddlRows.map((r) => r.read<String>('sql')).toList();
    await schemaV3Db.close();

    final rawDb = sqlite3.sqlite3.openInMemory();
    for (final statement in schemaV3Ddl) {
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
        INSERT INTO allenamenti
          (id, id_profilo, nome, tipo_allenamento, livello, stato, origine,
           attivo, data_creazione, data_modifica)
        VALUES (1, 1, 'Scheda pre-esistente', 'FULL_BODY', 1, 'READY',
                'USER', 1, ?, ?);
        ''',
      [now, now],
    );
    rawDb.execute(
      '''
        INSERT INTO allenamenti_esercizi
          (id, id_allenamento, id_esercizio, ordine, serie, ripetizioni,
           attivo, data_creazione, data_modifica)
        VALUES (1, 1, 1, 1, 3, 10, 1, ?, ?);
        ''',
      [now, now],
    );

    // Segna il database come "già a schema 3": scatena onUpgrade(3, 4)
    // all'apertura, esattamente come su un dispositivo reale.
    rawDb.execute('PRAGMA user_version = 3;');

    final database = AppDatabase(NativeDatabase.opened(rawDb));
    addTearDown(database.close);

    // 1. Dati precedenti preservati.
    expect(database.schemaVersion, 6);
    final profile = await database.userProfileDao.getCurrentProfile();
    expect(profile, isNotNull);
    expect(profile!.name, 'Alex');

    final esercizi = await database.select(database.eserciziTable).get();
    expect(esercizi, hasLength(1));
    expect(esercizi.single.codice, 'MOB-001');

    final allenamenti = await database.select(database.allenamentiTable).get();
    expect(allenamenti, hasLength(1));
    expect(allenamenti.single.nome, 'Scheda pre-esistente');

    final righeScheda = await database
        .select(database.allenamentiEserciziTable)
        .get();
    expect(righeScheda, hasLength(1));
    expect(righeScheda.single.serie, 3);

    // 2. Le nuove tabelle della Milestone 4.4.3 sono disponibili e vuote.
    expect(
      await database.select(database.sessioniAllenamentoTable).get(),
      isEmpty,
    );
    expect(
      await database.select(database.sessioniEserciziTable).get(),
      isEmpty,
    );

    // 3. La nuova struttura funziona davvero sul database migrato: una
    // sessione può essere creata e collegata alla scheda/esercizio
    // preservati dalla migrazione.
    final idSessione = await database
        .into(database.sessioniAllenamentoTable)
        .insert(
          SessioniAllenamentoTableCompanion.insert(
            idAllenamento: const Value(1),
            idProfilo: 1,
            nomeAllenamentoSnapshot: 'Scheda pre-esistente',
            stato: 'IN_PROGRESS',
            dataInizio: DateTime.now(),
            dataCreazione: DateTime.now(),
            dataModifica: DateTime.now(),
          ),
        );
    await database
        .into(database.sessioniEserciziTable)
        .insert(
          SessioniEserciziTableCompanion.insert(
            idSessione: idSessione,
            idAllenamentoEsercizio: const Value(1),
            idEsercizio: 1,
            ordine: 1,
            serieTotali: 3,
            dataCreazione: DateTime.now(),
            dataModifica: DateTime.now(),
          ),
        );
    expect(
      await database.select(database.sessioniEserciziTable).get(),
      hasLength(1),
    );
  });
}
