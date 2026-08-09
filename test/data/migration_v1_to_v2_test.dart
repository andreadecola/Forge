import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/data/database/app_database.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite3;

/// Simula un'installazione reale della Milestone 2 (schema 1, tabelle con
/// nomi fisici inglesi) e verifica che l'upgrade a schema 2 (Milestone 3.1):
/// - rinomini le tabelle in italiano senza perdere righe;
/// - crei le nuove tabelle del catalogo esercizi.
void main() {
  test(
    'upgrade da schema 1 a schema 2 preserva i dati M2 e crea le tabelle catalogo',
    () async {
      final rawDb = sqlite3.sqlite3.openInMemory();

      // Schema 1 "a mano": stessa struttura delle tabelle Milestone 2 prima
      // della rinomina in italiano (nomi fisici inglesi).
      rawDb.execute('''
        CREATE TABLE user_profiles_table (
          id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          birth_date INTEGER NOT NULL,
          biological_sex_for_formula TEXT NULL,
          height_cm REAL NOT NULL,
          initial_weight_kg REAL NOT NULL,
          target_weight_kg REAL NULL,
          preferred_walk_minutes INTEGER NOT NULL,
          equipment_budget_limit REAL NOT NULL,
          start_date INTEGER NOT NULL,
          activity_level TEXT NULL,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL
        );
      ''');
      rawDb.execute('''
        CREATE TABLE body_measurements_table (
          id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          profile_id INTEGER NOT NULL REFERENCES user_profiles_table (id),
          measured_at INTEGER NOT NULL,
          weight_kg REAL NOT NULL,
          neck_cm REAL NULL,
          chest_cm REAL NULL,
          waist_cm REAL NULL,
          abdomen_cm REAL NULL,
          hips_cm REAL NULL,
          left_arm_cm REAL NULL,
          right_arm_cm REAL NULL,
          left_thigh_cm REAL NULL,
          right_thigh_cm REAL NULL,
          left_calf_cm REAL NULL,
          right_calf_cm REAL NULL,
          notes TEXT NULL
        );
      ''');
      rawDb.execute('''
        CREATE TABLE pressure_measurements_table (
          id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          profile_id INTEGER NOT NULL REFERENCES user_profiles_table (id),
          measured_at INTEGER NOT NULL,
          systolic INTEGER NOT NULL,
          diastolic INTEGER NOT NULL,
          heart_rate INTEGER NULL,
          measurement_context TEXT NULL,
          notes TEXT NULL
        );
      ''');
      rawDb.execute('''
        CREATE TABLE user_equipment_table (
          id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          profile_id INTEGER NOT NULL REFERENCES user_profiles_table (id),
          equipment_code TEXT NOT NULL,
          owned INTEGER NOT NULL DEFAULT 0,
          acquired_at INTEGER NULL,
          notes TEXT NULL,
          UNIQUE (profile_id, equipment_code)
        );
      ''');
      rawDb.execute('''
        CREATE TABLE app_settings_table (
          "key" TEXT NOT NULL PRIMARY KEY,
          value TEXT NOT NULL
        );
      ''');

      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      rawDb.execute(
        '''
        INSERT INTO user_profiles_table
          (name, birth_date, height_cm, initial_weight_kg,
           preferred_walk_minutes, equipment_budget_limit, start_date,
           created_at, updated_at)
        VALUES ('Alex', ?, 175, 80, 30, 50, ?, ?, ?);
        ''',
        [now, now, now, now],
      );

      rawDb.execute(
        '''
        INSERT INTO body_measurements_table (profile_id, measured_at, weight_kg)
        VALUES (1, ?, 78.5);
        ''',
        [now],
      );

      rawDb.execute(
        '''
        INSERT INTO pressure_measurements_table
          (profile_id, measured_at, systolic, diastolic)
        VALUES (1, ?, 120, 80);
        ''',
        [now],
      );

      rawDb.execute('''
        INSERT INTO user_equipment_table (profile_id, equipment_code, owned)
        VALUES (1, 'chair', 1);
      ''');

      rawDb.execute('''
        INSERT INTO app_settings_table ("key", value)
        VALUES ('onboardingCompleted', '1');
      ''');

      // Segna il database come "già a schema 1": è questo che fa scattare
      // onUpgrade(1, 2) all'apertura, esattamente come su un dispositivo
      // reale che aggiorna l'app.
      rawDb.execute('PRAGMA user_version = 1;');

      final database = AppDatabase(NativeDatabase.opened(rawDb));
      addTearDown(database.close);

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

      final onboardingCompleted = await database.appSettingsDao.getValue(
        'onboardingCompleted',
      );
      expect(onboardingCompleted, '1');

      // Le nuove tabelle del catalogo esercizi devono essere disponibili e
      // vuote (nessun seed in questa milestone).
      expect(
        await database.select(database.categorieEserciziTable).get(),
        isEmpty,
      );
      expect(await database.select(database.eserciziTable).get(), isEmpty);
      expect(
        await database.select(database.versioniCatalogoTable).get(),
        isEmpty,
      );
    },
  );
}
