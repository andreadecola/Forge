import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/data/database/app_database.dart';
import 'package:forge/data/repositories/drift_workout_repository.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite3;

void main() {
  test(
    'schema 11 -> 12 conserva le schede legacy e abilita il set livelli',
    () async {
      final rawDb = sqlite3.sqlite3.openInMemory();
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      rawDb.execute('''
      CREATE TABLE allenamenti (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_profilo INTEGER NOT NULL,
        nome TEXT NOT NULL,
        descrizione TEXT,
        tipo_allenamento TEXT NOT NULL,
        livello INTEGER NOT NULL DEFAULT 1,
        durata_stimata_minuti INTEGER,
        stato TEXT NOT NULL,
        origine TEXT NOT NULL,
        attivo INTEGER NOT NULL DEFAULT 1,
        data_creazione INTEGER NOT NULL,
        data_modifica INTEGER NOT NULL
      )
    ''');
      rawDb.execute(
        '''
      INSERT INTO allenamenti
        (id_profilo, nome, tipo_allenamento, livello, stato, origine,
         data_creazione, data_modifica)
      VALUES (1, 'Legacy', 'FULL_BODY', 3, 'DRAFT', 'USER', ?, ?)
    ''',
        [now, now],
      );
      rawDb.execute('PRAGMA user_version = 11');

      final database = AppDatabase(NativeDatabase.opened(rawDb));
      addTearDown(database.close);

      final repository = DriftWorkoutRepository(database);
      final legacy = await repository.getWorkoutById(1);
      expect(legacy, isNotNull);
      expect(legacy!.effectiveSelectedLevels, {3});

      await repository.updateWorkout(
        legacy.copyWith(level: 5, selectedLevels: {2, 5}),
      );
      final migrated = await repository.getWorkoutById(1);
      expect(migrated!.effectiveSelectedLevels, {2, 5});
      expect(migrated.level, 5);
    },
  );
}
