import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/data/database/app_database.dart';
import 'package:forge/data/repositories/drift_exercise_repository.dart';
import 'package:forge/data/seed/exercise_catalog_seeder.dart';
import 'package:forge/domain/entities/equipment.dart';
import 'package:forge/domain/entities/exercise_details.dart';
import 'package:forge/domain/entities/forge_generation_error.dart';
import 'package:forge/domain/entities/forge_request.dart';
import 'package:forge/domain/entities/workout_enums.dart';
import 'package:forge/domain/services/forge_engine.dart';
import 'package:forge/domain/services/forge_workout_generator.dart';

import 'forge_fixtures.dart';

/// Hardening (Milestone 5.6, sezioni 10-22): livello/durata/attrezzatura
/// estremi, catalogo vuoto/inattivo/completamente bloccato. Nessuna nuova
/// regola qui — solo verifica che il motore esistente si comporti in modo
/// controllato (mai un'eccezione non gestita) su input limite.
void main() {
  late List<ExerciseDetails> realCatalogDetails;

  setUpAll(() async {
    final db = AppDatabase(NativeDatabase.memory());
    final raw = File('assets/data/exercises_v1.json').readAsStringSync();
    await ExerciseCatalogSeeder(db).seedFromString(raw);
    final repository = DriftExerciseRepository(db);
    final exercises = await repository.getExercises();
    final detailsList = await Future.wait(
      exercises.map((e) => repository.getExerciseDetails(e.id)),
    );
    realCatalogDetails = detailsList.whereType<ExerciseDetails>().toList();
    await db.close();
  });

  const engine = ForgeEngine();
  const generator = ForgeWorkoutGenerator();

  group('livello (sezioni 10-12)', () {
    test('livello minimo (1): nessun eleggibile richiede livello > 1', () {
      final result = engine.evaluateExercises(
        const ForgeRequest(
          profileId: 1,
          userLevel: 1,
          availableEquipmentCodes: {},
          targetDurationMinutes: 30,
          workoutType: WorkoutType.fullBody,
        ),
        realCatalogDetails,
      );
      for (final e in result.eligible) {
        expect(e.candidate.exercise.minimumLevel, lessThanOrEqualTo(1));
      }
    });

    test('livello molto alto (10, oltre i 5 offerti in UI): nessuna '
        'eccezione, pool eleggibile coerente (livello alto non esclude mai '
        "un esercizio per 'troppo facile' salvo maximumLevel esplicito)", () {
      expect(
        () => engine.evaluateExercises(
          const ForgeRequest(
            profileId: 1,
            userLevel: 10,
            availableEquipmentCodes: {},
            targetDurationMinutes: 30,
            workoutType: WorkoutType.fullBody,
          ),
          realCatalogDetails,
        ),
        returnsNormally,
      );
      final level1 = engine.evaluateExercises(
        const ForgeRequest(
          profileId: 1,
          userLevel: 1,
          availableEquipmentCodes: {},
          targetDurationMinutes: 30,
          workoutType: WorkoutType.fullBody,
        ),
        realCatalogDetails,
      );
      final level10 = engine.evaluateExercises(
        const ForgeRequest(
          profileId: 1,
          userLevel: 10,
          availableEquipmentCodes: {},
          targetDurationMinutes: 30,
          workoutType: WorkoutType.fullBody,
        ),
        realCatalogDetails,
      );
      expect(
        level10.eligible.length,
        greaterThanOrEqualTo(level1.eligible.length),
        reason: 'un livello piu\' alto sblocca esercizi, non li nasconde',
      );
    });

    test('livello non valido (<= 0): richiesta invalida, nessun eleggibile, '
        'nessuna eccezione (sezione 12)', () {
      for (final invalidLevel in [0, -1, -100]) {
        final result = engine.evaluateExercises(
          ForgeRequest(
            profileId: 1,
            userLevel: invalidLevel,
            availableEquipmentCodes: const {},
            targetDurationMinutes: 30,
            workoutType: WorkoutType.fullBody,
          ),
          realCatalogDetails,
        );
        expect(result.eligible, isEmpty);
        expect(result.excluded, isEmpty);
        expect(result.warnings, isNotEmpty);

        final generated = generator.generate(result);
        expect(generated.success, isFalse);
        expect(generated.plan, isNull);
        expect(generated.errors, contains(ForgeGenerationError.invalidRequest));
      }
    });
  });

  group('durata (sezioni 13-14)', () {
    test('durata estremamente breve (5 min): nessuna eccezione, nessun '
        'loop, esercizi entro maximumExercises', () {
      final result = generator.generate(
        engine.evaluateExercises(
          const ForgeRequest(
            profileId: 1,
            userLevel: 1,
            availableEquipmentCodes: {},
            targetDurationMinutes: 5,
            workoutType: WorkoutType.fullBody,
          ),
          realCatalogDetails,
        ),
      );
      if (result.plan != null) {
        expect(result.plan!.exercises.length, lessThanOrEqualTo(8));
        expect(
          result.plan!.exercises.toSet().length,
          result.plan!.exercises.length,
          reason: 'nessun esercizio duplicato',
        );
      }
    });

    test('durata molto lunga (180 min): esecuzione bounded, nessun loop '
        'infinito, nessuna duplicazione arbitraria', () {
      final result = generator.generate(
        engine.evaluateExercises(
          const ForgeRequest(
            profileId: 1,
            userLevel: 1,
            availableEquipmentCodes: {},
            targetDurationMinutes: 180,
            workoutType: WorkoutType.fullBody,
          ),
          realCatalogDetails,
        ),
      );
      expect(result.plan, isNotNull);
      expect(result.plan!.exercises.length, lessThanOrEqualTo(8));
      final codes = result.plan!.exercises.map((e) => e.exercise.code).toList();
      expect(codes.toSet().length, codes.length);
    });

    test('durata non valida (<= 0): richiesta invalida controllata', () {
      final result = generator.generate(
        engine.evaluateExercises(
          const ForgeRequest(
            profileId: 1,
            userLevel: 1,
            availableEquipmentCodes: {},
            targetDurationMinutes: 0,
            workoutType: WorkoutType.fullBody,
          ),
          realCatalogDetails,
        ),
      );
      expect(result.success, isFalse);
      expect(result.errors, contains(ForgeGenerationError.invalidRequest));
    });
  });

  group('attrezzatura (sezioni 15-17)', () {
    test('nessuna attrezzatura: generazione possibile dove il catalogo lo '
        'consente, nessun eleggibile richiede attrezzatura non posseduta', () {
      final result = engine.evaluateExercises(
        const ForgeRequest(
          profileId: 1,
          userLevel: 1,
          availableEquipmentCodes: {},
          targetDurationMinutes: 30,
          workoutType: WorkoutType.fullBody,
        ),
        realCatalogDetails,
      );
      expect(result.eligible, isNotEmpty);
      for (final e in result.eligible) {
        final required = e.candidate.requiredEquipmentCodes.difference({
          Equipment.noneCode,
        });
        expect(
          required,
          isEmpty,
          reason: '${e.candidate.exercise.code} richiede $required',
        );
      }
    });

    test('tutta l\'attrezzatura master posseduta: nessuna eccezione, pool '
        'ampliato, determinismo invariato', () {
      const allEquipment = {'CHAIR', 'WALL', 'MAT', 'BAND', 'DUMBBELL', 'STEP'};
      final withAll = engine.evaluateExercises(
        const ForgeRequest(
          profileId: 1,
          userLevel: 1,
          availableEquipmentCodes: allEquipment,
          targetDurationMinutes: 30,
          workoutType: WorkoutType.fullBody,
        ),
        realCatalogDetails,
      );
      final withNone = engine.evaluateExercises(
        const ForgeRequest(
          profileId: 1,
          userLevel: 1,
          availableEquipmentCodes: {},
          targetDurationMinutes: 30,
          workoutType: WorkoutType.fullBody,
        ),
        realCatalogDetails,
      );
      expect(
        withAll.eligible.length,
        greaterThanOrEqualTo(withNone.eligible.length),
      );

      final a = engine.evaluateExercises(
        const ForgeRequest(
          profileId: 1,
          userLevel: 1,
          availableEquipmentCodes: allEquipment,
          targetDurationMinutes: 30,
          workoutType: WorkoutType.fullBody,
        ),
        realCatalogDetails,
      );
      expect(
        a.eligible.map((e) => e.candidate.exercise.code).toList(),
        withAll.eligible.map((e) => e.candidate.exercise.code).toList(),
      );
    });

    test(
      'attrezzatura specifica (es. STEP): assente esclude gli esercizi '
      'che la richiedono, presente li rende eleggibili se gli altri '
      'vincoli sono validi (sezione 17 — nessun codice HOUSEHOLD nel '
      'catalogo reale: verificato con un codice master reale equivalente)',
      () {
        final without = engine.evaluateExercises(
          const ForgeRequest(
            profileId: 1,
            userLevel: 1,
            availableEquipmentCodes: {},
            targetDurationMinutes: 30,
            workoutType: WorkoutType.fullBody,
          ),
          realCatalogDetails,
        );
        final withStep = engine.evaluateExercises(
          const ForgeRequest(
            profileId: 1,
            userLevel: 1,
            availableEquipmentCodes: {'STEP'},
            targetDurationMinutes: 30,
            workoutType: WorkoutType.fullBody,
          ),
          realCatalogDetails,
        );
        final stepOnlyExcludedWithout = without.excluded.where(
          (e) =>
              e.eligibility.reasons.length == 1 &&
              e.eligibility.reasons.single.name == 'missingEquipment' &&
              e.candidate.requiredEquipmentCodes.difference({
                'STEP',
                Equipment.noneCode,
              }).isEmpty &&
              e.candidate.requiredEquipmentCodes.contains('STEP'),
        );
        for (final excludedEntry in stepOnlyExcludedWithout) {
          final nowEligible = withStep.eligible.any(
            (e) =>
                e.candidate.exercise.code ==
                excludedEntry.candidate.exercise.code,
          );
          expect(
            nowEligible,
            isTrue,
            reason:
                '${excludedEntry.candidate.exercise.code} richiedeva solo STEP',
          );
        }
      },
    );
  });

  group('catalogo degenerato (sezioni 18-22)', () {
    test('catalogo vuoto: fallimento controllato, nessuna eccezione', () {
      final result = generator.generate(
        engine.evaluateExercises(
          const ForgeRequest(
            profileId: 1,
            userLevel: 1,
            availableEquipmentCodes: {},
            targetDurationMinutes: 30,
            workoutType: WorkoutType.fullBody,
          ),
          const [],
        ),
      );
      expect(result.success, isFalse);
      expect(
        result.errors,
        contains(ForgeGenerationError.insufficientEligibleExercises),
      );
    });

    test(
      'tutti gli esercizi inactive: tutti esclusi, fallimento controllato',
      () {
        final details = [
          for (var i = 0; i < 5; i++)
            buildExerciseDetails(
              exercise: buildExercise(
                id: i,
                code: 'INA-$i',
                isActive: false,
                defaultReps: 10,
              ),
            ),
        ];
        final evaluation = engine.evaluateExercises(
          const ForgeRequest(
            profileId: 1,
            userLevel: 1,
            availableEquipmentCodes: {},
            targetDurationMinutes: 30,
            workoutType: WorkoutType.fullBody,
          ),
          details,
        );
        expect(evaluation.eligible, isEmpty);
        expect(evaluation.excluded.length, 5);
        for (final e in evaluation.excluded) {
          expect(e.eligibility.reasons, contains(anything));
        }
        final result = generator.generate(evaluation);
        expect(result.success, isFalse);
      },
    );

    test('tutti gli esercizi bloccati per livello: fallimento spiegabile', () {
      final details = [
        for (var i = 0; i < 5; i++)
          buildExerciseDetails(
            exercise: buildExercise(
              id: i,
              code: 'LVL-$i',
              minimumLevel: 99,
              defaultReps: 10,
            ),
          ),
      ];
      final evaluation = engine.evaluateExercises(
        const ForgeRequest(
          profileId: 1,
          userLevel: 1,
          availableEquipmentCodes: {},
          targetDurationMinutes: 30,
          workoutType: WorkoutType.fullBody,
        ),
        details,
      );
      expect(evaluation.eligible, isEmpty);
      expect(evaluation.excluded.length, 5);
      final result = generator.generate(evaluation);
      expect(result.success, isFalse);
      expect(
        result.errors,
        contains(ForgeGenerationError.insufficientEligibleExercises),
      );
    });

    test(
      'tutti gli esercizi bloccati per attrezzatura: fallimento spiegabile',
      () {
        final details = [
          for (var i = 0; i < 5; i++)
            buildExerciseDetails(
              exercise: buildExercise(id: i, code: 'EQ-$i', defaultReps: 10),
              requiredEquipmentCodes: const ['DUMBBELL'],
            ),
        ];
        final evaluation = engine.evaluateExercises(
          const ForgeRequest(
            profileId: 1,
            userLevel: 1,
            availableEquipmentCodes: {},
            targetDurationMinutes: 30,
            workoutType: WorkoutType.fullBody,
          ),
          details,
        );
        expect(evaluation.eligible, isEmpty);
        final result = generator.generate(evaluation);
        expect(result.success, isFalse);
        expect(
          result.errors,
          contains(ForgeGenerationError.insufficientEligibleExercises),
        );
      },
    );

    test('pool eleggibile insufficiente a coprire la copertura obbligatoria '
        '(solo una delle due categorie richieste da FULL_BODY): '
        'missingRequiredCoverage, coverage non aggirata', () {
      final details = [
        for (var i = 0; i < 3; i++)
          buildExerciseDetails(
            exercise: buildExercise(id: i, code: 'PS-$i', defaultReps: 10),
            categoryCode: 'PETTO_SPINTA',
          ),
      ];
      final evaluation = engine.evaluateExercises(
        const ForgeRequest(
          profileId: 1,
          userLevel: 1,
          availableEquipmentCodes: {},
          targetDurationMinutes: 30,
          workoutType: WorkoutType.fullBody,
        ),
        details,
      );
      final result = generator.generate(evaluation);
      expect(result.success, isFalse);
      expect(
        result.errors,
        contains(ForgeGenerationError.missingRequiredCoverage),
      );
      // Il piano di miglior tentativo non deve mai contenere piu' esercizi
      // "PETTO_SPINTA" di quanti eleggibili esistano, e mai inventare
      // GAMBE_GLUTEI dal nulla.
      if (result.plan != null) {
        expect(
          result.plan!.exercises.every((e) => e.exercise.code.startsWith('PS')),
          isTrue,
        );
      }
    });
  });
}
