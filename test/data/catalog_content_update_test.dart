import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/data/database/app_database.dart';
import 'package:forge/data/seed/exercise_catalog_seeder.dart';

/// Simula un dispositivo che ha già importato la Milestone 3.2
/// (catalogVersion 1, contenuti placeholder) e verifica che l'aggiornamento
/// a catalogVersion 2 (Milestone 3.3.1, contenuti reali):
/// - non venga bloccato dal gate di idempotenza (versione diversa);
/// - non duplichi esercizi o relazioni;
/// - sostituisca i contenuti placeholder con quelli reali.
void main() {
  late AppDatabase db;
  late String realJson;

  setUpAll(() {
    realJson = File('assets/data/exercises_v1.json').readAsStringSync();
  });

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  test(
    'v1 già importata (placeholder) -> v2 applicata -> contenuti aggiornati, nessun duplicato',
    () async {
      // Costruisce una v1 "storica": stessa struttura del file reale, ma
      // catalogVersion 1 e instructions ancora al placeholder della M3.2.
      final v1Data = json.decode(realJson) as Map<String, dynamic>;
      v1Data['catalogVersion'] = 1;
      final exercises = (v1Data['exercises'] as List<dynamic>)
          .cast<Map<String, dynamic>>();
      for (final e in exercises) {
        e['instructions'] =
            'Istruzioni dettagliate da definire in una prossima iterazione di contenuto.';
      }
      final v1Json = jsonEncode(v1Data);

      final seeder = ExerciseCatalogSeeder(db);

      final firstImport = await seeder.seedFromString(v1Json);
      expect(firstImport.alreadyImported, isFalse);
      expect(firstImport.exercises, 118);

      final push001Before = await db.eserciziDao.getByCode('PUSH-001');
      expect(
        push001Before!.istruzioni,
        contains('da definire in una prossima iterazione'),
      );

      // Applica il catalogo reale (v2, contenuti completati).
      final secondImport = await seeder.seedFromString(realJson);
      expect(
        secondImport.alreadyImported,
        isFalse,
        reason: 'catalogVersion 2 non era ancora registrata: deve importare',
      );
      expect(secondImport.exercises, 118);

      // Nessun duplicato: stesso numero di righe di prima.
      final allExercises = await db.eserciziDao.getAll();
      expect(allExercises, hasLength(118));

      // Il contenuto è stato aggiornato, non duplicato.
      final push001After = await db.eserciziDao.getByCode('PUSH-001');
      expect(
        push001After!.istruzioni,
        isNot(contains('da definire in una prossima iterazione')),
      );
      expect(push001After.id, push001Before.id); // stessa riga, aggiornata.

      // Relazioni ricostruite correttamente (non duplicate).
      final images = await db.immaginiEserciziDao.getForExercise(
        push001After.id,
      );
      expect(images, hasLength(2));
      final muscles = await db.gruppiMuscolariDao.getPrimaryMusclesForExercise(
        push001After.id,
      );
      expect(muscles.map((m) => m.codice), contains('PETTORALI'));

      // Storico versioni preservato: sia v1 che v2 registrate.
      final versions = await db.select(db.versioniCatalogoTable).get();
      expect(versions.map((v) => v.versione), containsAll([1, 2]));
    },
  );

  test('seconda applicazione della stessa v2 resta idempotente', () async {
    final seeder = ExerciseCatalogSeeder(db);
    await seeder.seedFromString(realJson);
    final result = await seeder.seedFromString(realJson);
    expect(result.alreadyImported, isTrue);
    final allExercises = await db.eserciziDao.getAll();
    expect(allExercises, hasLength(118));
  });
}
