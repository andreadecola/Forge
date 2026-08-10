import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:forge/data/seed/exercise_catalog_seeder.dart';
import 'package:forge/data/seed/models/exercise_catalog_seed_models.dart';

/// Validazione dei contenuti reali introdotti nella Milestone 3.3.1: nessun
/// placeholder residuo, campi obbligatori popolati, struttura/conteggi del
/// catalogo invariati rispetto alla Milestone 3.2.
void main() {
  late ExerciseCatalogSeedModel catalog;
  late String rawJson;

  setUpAll(() {
    rawJson = File('assets/data/exercises_v1.json').readAsStringSync();
    catalog = ExerciseCatalogSeeder.parse(rawJson);
  });

  test('catalogVersion è 2 (contenuti Milestone 3.3.1)', () {
    expect(catalog.catalogVersion, 2);
  });

  test(
    'conteggi catalogo invariati: 118 esercizi, 10 categorie, 16 muscoli, 8 attrezzature',
    () {
      expect(catalog.exercises, hasLength(118));
      expect(catalog.categories, hasLength(10));
      expect(catalog.muscleGroups, hasLength(16));
      expect(catalog.equipment, hasLength(8));
    },
  );

  test(
    'description è popolata e non è un placeholder per tutti gli esercizi',
    () {
      for (final e in catalog.exercises) {
        expect(e.description.trim(), isNotEmpty, reason: e.code);
        expect(
          e.description,
          isNot(contains('della categoria')),
          reason:
              '${e.code}: sembra il placeholder strutturale della Milestone 3.2',
        );
      }
    },
  );

  test(
    'instructions è popolata, con più passaggi, e non è il placeholder M3.2',
    () {
      for (final e in catalog.exercises) {
        expect(e.instructions.trim(), isNotEmpty, reason: e.code);
        expect(
          e.instructions,
          isNot(contains('da definire in una prossima iterazione')),
          reason: '${e.code}: placeholder della Milestone 3.2 non sostituito',
        );
        // Formato "1. ...": almeno un passaggio numerato.
        expect(e.instructions, contains('1.'), reason: e.code);
      }
    },
  );

  test('breathingInstructions è popolato per tutti gli esercizi', () {
    for (final e in catalog.exercises) {
      expect(e.breathingInstructions, isNotNull, reason: e.code);
      expect(e.breathingInstructions!.trim(), isNotEmpty, reason: e.code);
    }
  });

  test('commonMistakes è popolato per tutti gli esercizi', () {
    for (final e in catalog.exercises) {
      expect(e.commonMistakes, isNotNull, reason: e.code);
      expect(e.commonMistakes!.trim(), isNotEmpty, reason: e.code);
    }
  });

  test(
    'safetyNotes è popolato per gli esercizi che richiedono attrezzatura o supporto',
    () {
      for (final e in catalog.exercises) {
        final requiresEquipmentOrSupport =
            e.equipmentCodes.any((eq) => eq.code != 'NONE') || e.supportAllowed;
        if (requiresEquipmentOrSupport) {
          expect(
            e.safetyNotes,
            isNotNull,
            reason:
                '${e.code}: richiede attrezzatura/supporto ma safetyNotes è null',
          );
          expect(e.safetyNotes!.trim(), isNotEmpty, reason: e.code);
        }
      }
    },
  );

  test('nessun campo contiene TODO, placeholder o testo residuo di bozza', () {
    final forbidden = ['TODO', 'todo', 'placeholder', 'Placeholder', 'FIXME'];
    for (final e in catalog.exercises) {
      final fields = [
        e.description,
        e.instructions,
        e.breathingInstructions,
        e.commonMistakes,
        e.safetyNotes,
      ];
      for (final field in fields) {
        if (field == null) continue;
        for (final term in forbidden) {
          expect(
            field.contains(term),
            isFalse,
            reason: '${e.code}: contiene "$term"',
          );
        }
      }
    }
  });

  test('nessun campo contiene URL remoti', () {
    for (final e in catalog.exercises) {
      final fields = [
        e.description,
        e.instructions,
        e.breathingInstructions,
        e.commonMistakes,
        e.safetyNotes,
      ];
      for (final field in fields) {
        if (field == null) continue;
        expect(field, isNot(contains('http://')), reason: e.code);
        expect(field, isNot(contains('https://')), reason: e.code);
        expect(field, isNot(contains('www.')), reason: e.code);
      }
    }
  });

  test(
    'nessun campo contiene linguaggio diagnostico o prescrittivo assoluto',
    () {
      // Formulazioni da evitare secondo il principio "Forge non è un'app medica".
      final forbiddenPhrases = [
        'cura ',
        'guarisce',
        'diagnosi',
        'prescriv',
        'terapia',
        'terapeutic',
        'garantisce',
        'elimina il dolore',
        'risolve il problema',
      ];
      for (final e in catalog.exercises) {
        final fields = [
          e.description,
          e.instructions,
          e.breathingInstructions,
          e.commonMistakes,
          e.safetyNotes,
        ];
        for (final field in fields) {
          if (field == null) continue;
          final lower = field.toLowerCase();
          for (final phrase in forbiddenPhrases) {
            expect(
              lower.contains(phrase),
              isFalse,
              reason: '${e.code}: contiene linguaggio non prudente ("$phrase")',
            );
          }
        }
      }
    },
  );

  test(
    'progressionCode, alternativeCode, muscleCode ed equipmentCode restano validi',
    () {
      final exerciseCodes = catalog.exercises.map((e) => e.code).toSet();
      final muscleCodes = catalog.muscleGroups.map((m) => m.code).toSet();
      final equipmentCodes = catalog.equipment.map((eq) => eq.code).toSet();

      for (final e in catalog.exercises) {
        if (e.progressionCode != null) {
          expect(exerciseCodes, contains(e.progressionCode));
        }
        for (final alt in e.alternativeCodes) {
          expect(exerciseCodes, contains(alt.code));
        }
        for (final m in [...e.primaryMuscleCodes, ...e.secondaryMuscleCodes]) {
          expect(muscleCodes, contains(m));
        }
        for (final eq in e.equipmentCodes) {
          expect(equipmentCodes, contains(eq.code));
        }
      }
    },
  );

  test(
    'il JSON grezzo non contiene residui testuali di bozza (regex ampia)',
    () {
      expect(rawJson.contains('TODO'), isFalse);
      expect(rawJson.contains('placeholder'), isFalse);
      expect(
        rawJson.contains('da definire in una prossima iterazione'),
        isFalse,
      );
    },
  );
}
