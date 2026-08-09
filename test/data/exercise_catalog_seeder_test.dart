import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/data/database/app_database.dart';
import 'package:forge/data/seed/exercise_catalog_seeder.dart';

/// Import del catalogo su database in-memory: conteggi, idempotenza, rollback.
void main() {
  late AppDatabase db;
  late ExerciseCatalogSeeder seeder;
  late String rawJson;

  setUpAll(() {
    rawJson = File('assets/data/exercises_v1.json').readAsStringSync();
  });

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    seeder = ExerciseCatalogSeeder(db);
  });

  tearDown(() => db.close());

  Future<int> countOf<T extends HasResultSet, R>(
    ResultSetImplementation<T, R> table,
  ) async {
    final rows = await db.select(table).get();
    return rows.length;
  }

  test(
    'import popola tutte le tabelle del catalogo con i conteggi attesi',
    () async {
      final result = await seeder.seedFromString(rawJson);

      expect(result.alreadyImported, isFalse);
      expect(result.categories, 10);
      expect(result.muscleGroups, 16);
      expect(result.equipment, 8);
      expect(result.exercises, 118);
      expect(result.muscleRelations, greaterThan(0));
      expect(result.equipmentRelations, greaterThan(0));
      expect(result.images, 118 * 2);
      expect(result.progressions, greaterThan(0));
      expect(result.alternatives, greaterThan(0));

      expect(await countOf(db.categorieEserciziTable), 10);
      expect(await countOf(db.gruppiMuscolariTable), 16);
      expect(await countOf(db.attrezzatureTable), 8);
      expect(await countOf(db.eserciziTable), 118);
      expect(
        await countOf(db.eserciziGruppiMuscolariTable),
        result.muscleRelations,
      );
      expect(
        await countOf(db.attrezzatureEserciziTable),
        result.equipmentRelations,
      );
      expect(await countOf(db.immaginiEserciziTable), result.images);
      expect(await countOf(db.progressioniEserciziTable), result.progressions);
      expect(await countOf(db.alternativeEserciziTable), result.alternatives);
      expect(await countOf(db.versioniCatalogoTable), 1);
    },
  );

  test('le attrezzature master attese sono presenti dopo l\'import', () async {
    await seeder.seedFromString(rawJson);
    final codes = (await db.select(db.attrezzatureTable).get())
        .map((e) => e.codice)
        .toSet();
    expect(
      codes,
      containsAll([
        'NONE',
        'CHAIR',
        'WALL',
        'MAT',
        'BAND',
        'DUMBBELL',
        'STEP',
        'HOUSEHOLD',
      ]),
    );
  });

  test(
    'un esercizio importato ha relazioni muscoli, attrezzatura e immagini',
    () async {
      await seeder.seedFromString(rawJson);

      final push001 = await (db.select(
        db.eserciziTable,
      )..where((t) => t.codice.equals('PUSH-001'))).getSingle();

      final muscles = await (db.select(
        db.eserciziGruppiMuscolariTable,
      )..where((t) => t.idEsercizio.equals(push001.id))).get();
      expect(muscles, isNotEmpty);
      expect(muscles.any((m) => m.tipoCoinvolgimento == 'PRIMARIO'), isTrue);

      final equipment = await (db.select(
        db.attrezzatureEserciziTable,
      )..where((t) => t.idEsercizio.equals(push001.id))).get();
      expect(equipment, isNotEmpty);

      final images = await (db.select(
        db.immaginiEserciziTable,
      )..where((t) => t.idEsercizio.equals(push001.id))).get();
      expect(images, hasLength(2));
    },
  );

  test(
    'la progressione è registrata e la regressione si ottiene invertendo la query',
    () async {
      await seeder.seedFromString(rawJson);

      final leg001 = await (db.select(
        db.eserciziTable,
      )..where((t) => t.codice.equals('LEG-001'))).getSingle();
      final leg003 = await (db.select(
        db.eserciziTable,
      )..where((t) => t.codice.equals('LEG-003'))).getSingle();

      // Progressione diretta: LEG-001 -> LEG-003.
      final progression = await (db.select(
        db.progressioniEserciziTable,
      )..where((t) => t.idEsercizio.equals(leg001.id))).get();
      expect(
        progression.any((p) => p.idEsercizioSuccessivo == leg003.id),
        isTrue,
      );

      // Regressione di LEG-003: query inversa (chi progredisce verso LEG-003).
      final regression = await (db.select(
        db.progressioniEserciziTable,
      )..where((t) => t.idEsercizioSuccessivo.equals(leg003.id))).get();
      expect(regression.any((p) => p.idEsercizio == leg001.id), isTrue);
    },
  );

  test('import idempotente: due esecuzioni non duplicano i record', () async {
    final first = await seeder.seedFromString(rawJson);
    expect(first.alreadyImported, isFalse);

    final eserciziDopoPrimo = await countOf(db.eserciziTable);
    final relazioniDopoPrimo = await countOf(db.eserciziGruppiMuscolariTable);

    final second = await seeder.seedFromString(rawJson);
    expect(second.alreadyImported, isTrue);

    expect(await countOf(db.eserciziTable), eserciziDopoPrimo);
    expect(await countOf(db.eserciziGruppiMuscolariTable), relazioniDopoPrimo);
    expect(await countOf(db.versioniCatalogoTable), 1);
  });

  test(
    'rollback: un catalogo con progressionCode inesistente non lascia record parziali',
    () async {
      final decoded = json.decode(rawJson) as Map<String, dynamic>;
      final exercises = (decoded['exercises'] as List<dynamic>)
          .cast<Map<String, dynamic>>();
      // Rende invalido il catalogo puntando a un esercizio inesistente.
      exercises.first['progressionCode'] = 'NON-ESISTENTE-999';
      final invalidJson = jsonEncode(decoded);

      // La validazione è sincrona (fail-fast, prima della transazione):
      // la chiamata solleva immediatamente, quindi si verifica con una closure.
      expect(
        () => seeder.seedFromString(invalidJson),
        throwsA(isA<CatalogSeedException>()),
      );

      // Nessun record deve essere stato scritto.
      expect(await countOf(db.categorieEserciziTable), 0);
      expect(await countOf(db.eserciziTable), 0);
      expect(await countOf(db.versioniCatalogoTable), 0);
    },
  );
}
