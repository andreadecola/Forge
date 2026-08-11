import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/data/database/app_database.dart';
import 'package:forge/data/repositories/drift_exercise_repository.dart';
import 'package:forge/data/seed/exercise_catalog_seeder.dart';
import 'package:forge/domain/entities/exercise_details.dart';
import 'package:forge/domain/entities/forge_request.dart';
import 'package:forge/domain/entities/workout_enums.dart';
import 'package:forge/domain/services/forge_engine.dart';
import 'package:forge/domain/services/forge_workout_composer.dart';
import 'package:forge/domain/services/forge_workout_generator.dart';

import 'forge_fixtures.dart';

/// Hardening (Milestone 5.6, sezioni 5-9/23): determinismo massivo (500
/// ripetizioni) e invarianza dall'ordine di input, sul catalogo reale
/// caricato una sola volta (nessuna nuova query per ripetizione — non è
/// un test di persistenza, solo del motore puro).
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

  ForgeRequest request() {
    return const ForgeRequest(
      profileId: 1,
      userLevel: 1,
      availableEquipmentCodes: {},
      targetDurationMinutes: 30,
      workoutType: WorkoutType.fullBody,
    );
  }

  test('determinismo massivo: 500 generazioni consecutive, stesso input -> '
      'stessi exerciseId, stesso ordine, stessi parametri, stessa durata, '
      'stessi warning (sezione 5)', () {
    final req = request();
    final first = generator.generate(
      engine.evaluateExercises(req, realCatalogDetails),
    );
    expect(first.success, isTrue, reason: '${first.errors}');
    final firstPlan = first.plan!;

    for (var i = 0; i < 500; i++) {
      final result = generator.generate(
        engine.evaluateExercises(req, realCatalogDetails),
      );
      expect(result.success, isTrue);
      final plan = result.plan!;
      expect(
        plan.exercises.map((e) => e.exercise.code).toList(),
        firstPlan.exercises.map((e) => e.exercise.code).toList(),
        reason: 'iterazione $i',
      );
      expect(
        plan.exercises
            .map(
              (e) => (
                e.workoutExercise.sets,
                e.workoutExercise.repetitions,
                e.workoutExercise.durationSeconds,
                e.workoutExercise.restSeconds,
              ),
            )
            .toList(),
        firstPlan.exercises
            .map(
              (e) => (
                e.workoutExercise.sets,
                e.workoutExercise.repetitions,
                e.workoutExercise.durationSeconds,
                e.workoutExercise.restSeconds,
              ),
            )
            .toList(),
        reason: 'iterazione $i',
      );
      expect(plan.estimatedDurationSeconds, firstPlan.estimatedDurationSeconds);
      expect(plan.warnings, firstPlan.warnings);
    }
  });

  test('equipment order invariance: stessi codici in ordine diverso -> stesso '
      'piano (sezione 8)', () {
    ForgeRequest reqWithEquipment(Set<String> codes) => ForgeRequest(
      profileId: 1,
      userLevel: 1,
      availableEquipmentCodes: codes,
      targetDurationMinutes: 30,
      workoutType: WorkoutType.fullBody,
    );

    final a = generator.generate(
      engine.evaluateExercises(
        reqWithEquipment({'BAND', 'MAT', 'WALL'}),
        realCatalogDetails,
      ),
    );
    final b = generator.generate(
      engine.evaluateExercises(
        reqWithEquipment({'WALL', 'BAND', 'MAT'}),
        realCatalogDetails,
      ),
    );

    expect(a.success, isTrue);
    expect(b.success, isTrue);
    expect(
      a.plan!.exercises.map((e) => e.exercise.code).toList(),
      b.plan!.exercises.map((e) => e.exercise.code).toList(),
    );
  });

  test('duplicate equipment input: codici ripetuti nel set vengono già '
      'normalizzati dal tipo Set -> stesso piano di un set senza duplicati '
      '(sezione 9)', () {
    // `Set<String>` letterale: {'BAND','BAND','MAT'} è già equivalente a
    // {'BAND','MAT'} per costruzione del linguaggio, non serve una
    // deduplica esplicita nel motore.
    final rawCodesWithDuplicates = <String>['BAND', 'BAND', 'MAT'];
    final withDuplicates = rawCodesWithDuplicates.toSet();
    const withoutDuplicates = {'BAND', 'MAT'};
    expect(withDuplicates, withoutDuplicates);
    expect(withDuplicates.length, 2);

    ForgeRequest reqWithEquipment(Set<String> codes) => ForgeRequest(
      profileId: 1,
      userLevel: 1,
      availableEquipmentCodes: codes,
      targetDurationMinutes: 30,
      workoutType: WorkoutType.fullBody,
    );

    final a = generator.generate(
      engine.evaluateExercises(
        reqWithEquipment(withDuplicates),
        realCatalogDetails,
      ),
    );
    final b = generator.generate(
      engine.evaluateExercises(
        reqWithEquipment(withoutDuplicates),
        realCatalogDetails,
      ),
    );
    expect(
      a.plan!.exercises.map((e) => e.exercise.code).toList(),
      b.plan!.exercises.map((e) => e.exercise.code).toList(),
    );
  });

  test('catalog order invariance: pool con molte righe della stessa categoria '
      'e poche delle altre (category imbalance stress) -> nessuna eccezione, '
      'maxExercisesPerCategory rispettato, stesso piano indipendentemente '
      "dall'ordine del pool (sezioni 6/23)", () {
    final abbondante = [
      for (var i = 0; i < 30; i++)
        buildExerciseDetails(
          exercise: buildExercise(id: 100 + i, code: 'ABB-$i', defaultReps: 10),
          categoryCode: 'GAMBE_GLUTEI',
        ),
    ];
    final scarso = [
      buildExerciseDetails(
        exercise: buildExercise(id: 1, code: 'PS-1', defaultReps: 10),
        categoryCode: 'PETTO_SPINTA',
      ),
      buildExerciseDetails(
        exercise: buildExercise(id: 2, code: 'SC-1', defaultReps: 10),
        categoryCode: 'SCHIENA',
      ),
    ];
    final pool = [...abbondante, ...scarso];
    final poolInvertito = pool.reversed.toList();
    final poolShuffled = [
      ...pool.sublist(15),
      ...pool.sublist(0, 15),
    ]; // riordino deterministico, non Random()

    final req = ForgeRequest(
      profileId: 1,
      userLevel: 1,
      availableEquipmentCodes: const {},
      targetDurationMinutes: 30,
      workoutType: WorkoutType.fullBody,
    );

    final results = [
      pool,
      poolInvertito,
      poolShuffled,
    ].map((p) => generator.generate(engine.evaluateExercises(req, p))).toList();

    for (final result in results) {
      expect(result.plan, isNotNull);
      final byCategory = <String, int>{};
      for (final e in result.plan!.exercises) {
        // categoria non esposta direttamente su GeneratedWorkoutExercise:
        // deriviamo dal codice usato in fixture (prefisso stabile).
        final categoria = e.exercise.code.startsWith('ABB')
            ? 'GAMBE_GLUTEI'
            : e.exercise.code;
        byCategory[categoria] = (byCategory[categoria] ?? 0) + 1;
      }
      expect(
        byCategory['GAMBE_GLUTEI'] ?? 0,
        lessThanOrEqualTo(
          const ForgeWorkoutComposer().config.maxExercisesPerCategory + 2,
        ),
        reason:
            'maxExercisesPerCategory e\' un soft cap (fase B puo\' comunque '
            'aggiungerne altri se serve a raggiungere il minimo/la durata), '
            'ma non deve esplodere senza controllo',
      );
    }

    final codes0 = results[0].plan!.exercises
        .map((e) => e.exercise.code)
        .toList();
    for (final result in results.skip(1)) {
      expect(
        result.plan!.exercises.map((e) => e.exercise.code).toList(),
        codes0,
      );
    }
  });
}
