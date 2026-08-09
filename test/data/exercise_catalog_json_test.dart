import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:forge/data/seed/exercise_catalog_seeder.dart';
import 'package:forge/data/seed/models/exercise_catalog_seed_models.dart';

/// Validazioni statiche sul file `assets/data/exercises_v1.json` senza toccare
/// il database. `flutter test` gira con working directory = radice del
/// package, quindi il percorso relativo è affidabile.
void main() {
  late ExerciseCatalogSeedModel catalog;

  setUpAll(() {
    final raw = File('assets/data/exercises_v1.json').readAsStringSync();
    catalog = ExerciseCatalogSeeder.parse(raw);
  });

  test('il file JSON è leggibile e parsificabile', () {
    expect(catalog.exercises, isNotEmpty);
  });

  test('catalogType è ESERCIZI e catalogVersion è 1', () {
    expect(catalog.catalogType, 'ESERCIZI');
    expect(catalog.catalogVersion, 1);
  });

  test('i codici categoria sono univoci', () {
    final codes = catalog.categories.map((c) => c.code).toList();
    expect(codes.toSet().length, codes.length);
  });

  test('i codici gruppo muscolare sono univoci', () {
    final codes = catalog.muscleGroups.map((m) => m.code).toList();
    expect(codes.toSet().length, codes.length);
  });

  test('i codici attrezzatura sono univoci', () {
    final codes = catalog.equipment.map((e) => e.code).toList();
    expect(codes.toSet().length, codes.length);
  });

  test('i codici esercizio sono univoci', () {
    final codes = catalog.exercises.map((e) => e.code).toList();
    expect(codes.toSet().length, codes.length);
  });

  test('ogni categoryCode esiste tra le categorie', () {
    final categoryCodes = catalog.categories.map((c) => c.code).toSet();
    for (final e in catalog.exercises) {
      expect(
        categoryCodes,
        contains(e.categoryCode),
        reason: '${e.code} punta a categoria inesistente',
      );
    }
  });

  test('ogni equipmentCode esiste tra le attrezzature', () {
    final equipmentCodes = catalog.equipment.map((e) => e.code).toSet();
    for (final e in catalog.exercises) {
      for (final eq in e.equipmentCodes) {
        expect(
          equipmentCodes,
          contains(eq.code),
          reason: '${e.code} usa attrezzatura inesistente ${eq.code}',
        );
      }
    }
  });

  test('ogni muscleCode esiste tra i gruppi muscolari', () {
    final muscleCodes = catalog.muscleGroups.map((m) => m.code).toSet();
    for (final e in catalog.exercises) {
      for (final m in [...e.primaryMuscleCodes, ...e.secondaryMuscleCodes]) {
        expect(
          muscleCodes,
          contains(m),
          reason: '${e.code} usa muscolo inesistente $m',
        );
      }
    }
  });

  test('ogni progressionCode esiste e non è self-reference', () {
    final exerciseCodes = catalog.exercises.map((e) => e.code).toSet();
    for (final e in catalog.exercises) {
      final prog = e.progressionCode;
      if (prog != null) {
        expect(exerciseCodes, contains(prog));
        expect(prog, isNot(e.code));
      }
    }
  });

  test('ogni alternativeCode esiste e non è self-reference', () {
    final exerciseCodes = catalog.exercises.map((e) => e.code).toSet();
    for (final e in catalog.exercises) {
      for (final alt in e.alternativeCodes) {
        expect(exerciseCodes, contains(alt.code));
        expect(alt.code, isNot(e.code));
      }
    }
  });

  test('sono presenti le 8 attrezzature master attese', () {
    final codes = catalog.equipment.map((e) => e.code).toSet();
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

  test('parse rifiuta un JSON con progressione self-reference', () {
    final invalid = {
      'catalogType': 'ESERCIZI',
      'catalogVersion': 1,
      'categories': [
        {
          'code': 'MOBILITA',
          'name': 'Mobilità',
          'description': null,
          'displayOrder': 1,
          'active': true,
        },
      ],
      'muscleGroups': [
        {'code': 'CORE', 'name': 'Core', 'active': true},
      ],
      'equipment': [
        {'code': 'NONE', 'name': 'Nessuna', 'priority': 0, 'active': true},
      ],
      'exercises': [
        {
          'code': 'X-001',
          'name': 'Esercizio',
          'categoryCode': 'MOBILITA',
          'description': 'desc',
          'instructions': 'istr',
          'minimumLevel': 1,
          'impactLevel': 'LOW',
          'equipmentCodes': [
            {'code': 'NONE', 'required': true},
          ],
          'primaryMuscleCodes': ['CORE'],
          'secondaryMuscleCodes': <String>[],
          'progressionCode': 'X-001',
          'progressionType': 'VARIANTE',
          'alternativeCodes': <dynamic>[],
          'images': <dynamic>[],
        },
      ],
    };
    expect(
      () => ExerciseCatalogSeeder.parse(jsonEncode(invalid)),
      throwsA(isA<CatalogSeedException>()),
    );
  });
}
