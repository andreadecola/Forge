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

part 'weekly_plan_migration_v8_to_v9_test.g.dart';

/// Schema 8 realistico (fine Milestone 7.2): tutte le tabelle correnti
/// riusate senza modifiche — nessuna di esse è cambiata da schema 8 a 9,
/// l'unica novità di questa milestone è `attivita_pianificate`, qui
/// deliberatamente assente.
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
)
class _SchemaV8Database extends _$_SchemaV8Database {
  _SchemaV8Database(super.executor);

  @override
  int get schemaVersion => 8;
}

/// Fondamenta del Piano Settimanale (Milestone 8.1, sezioni 42-45):
/// verifica che l'upgrade reale 8 -> 9 (nuova tabella additiva) preservi
/// integralmente i dati M1-M7 e crei `attivita_pianificate` pienamente
/// funzionante — nessuna tabella esistente viene ricreata o modificata.
void main() {
  test('upgrade reale da schema 8 a 9 preserva i dati M7 e crea '
      '"attivita_pianificate"', () async {
    final schemaV8 = _SchemaV8Database(NativeDatabase.memory());
    await schemaV8.customSelect('SELECT 1').getSingle();
    final ddlRows = await schemaV8
        .customSelect(
          "SELECT sql FROM sqlite_master WHERE type IN ('table', 'index') "
          "AND sql IS NOT NULL AND name NOT LIKE 'sqlite_%'",
        )
        .get();
    final ddl = ddlRows.map((row) => row.read<String>('sql')).toList();
    await schemaV8.close();

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
      '''INSERT INTO misurazioni_corporee (id, profile_id, measured_at, weight_kg)
           VALUES (1, 1, ?, 79.5)''',
      [now],
    );
    rawDb.execute(
      '''INSERT INTO allenamenti
           (id, id_profilo, nome, tipo_allenamento, livello, stato, origine,
            attivo, data_creazione, data_modifica)
           VALUES (1, 1, 'Scheda gambe', 'LOWER_BODY', 1, 'READY', 'USER', 1, ?, ?)''',
      [now, now],
    );
    rawDb.execute('PRAGMA user_version = 8');

    final database = AppDatabase(NativeDatabase.opened(rawDb));
    addTearDown(database.close);

    expect(database.schemaVersion, 11);

    // Dati M7/M4 preservati, nessuna tabella preesistente toccata.
    final legacyBody = await database.bodyMeasurementsDao.getById(1);
    expect(legacyBody, isNotNull);
    expect(legacyBody!.weightKg, 79.5);
    final legacyWorkout = await database.allenamentiDao.getById(1);
    expect(legacyWorkout, isNotNull);
    expect(legacyWorkout!.nome, 'Scheda gambe');

    // Indice creato.
    final indexRows = await database
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'index' "
          "AND name = 'idx_attivita_pianificate_profilo_data'",
        )
        .get();
    expect(indexRows, hasLength(1));

    // Insert/read reali sulla nuova tabella, incluso il riferimento alla
    // scheda legacy preservata.
    final activityId = await database.attivitaPianificateDao.create(
      AttivitaPianificateTableCompanion.insert(
        idProfilo: 1,
        dataPianificata: DateTime(2026, 1, 5),
        tipo: 'WORKOUT',
        origine: 'USER',
        idAllenamento: const Value(1),
        dataCreazione: DateTime(2026, 1, 4),
        dataModifica: DateTime(2026, 1, 4),
      ),
    );
    final saved = await database.attivitaPianificateDao.getById(activityId);
    expect(saved, isNotNull);
    expect(saved!.tipo, 'WORKOUT');
    expect(saved.idAllenamento, 1);

    // Delete reale.
    await database.attivitaPianificateDao.deleteById(activityId);
    expect(await database.attivitaPianificateDao.getById(activityId), isNull);

    // FK ancora rispettata: profilo inesistente -> eccezione.
    expect(
      () => database.attivitaPianificateDao.create(
        AttivitaPianificateTableCompanion.insert(
          idProfilo: 999,
          dataPianificata: DateTime(2026, 1, 5),
          tipo: 'RECOVERY',
          origine: 'USER',
          dataCreazione: DateTime(2026, 1, 4),
          dataModifica: DateTime(2026, 1, 4),
        ),
      ),
      throwsA(anything),
    );
  });
}
