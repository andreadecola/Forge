import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/data/database/app_database.dart';
import 'package:forge/data/repositories/drift_exercise_repository.dart';
import 'package:forge/data/repositories/drift_workout_repository.dart';
import 'package:forge/data/repositories/drift_workout_session_repository.dart';
import 'package:forge/data/seed/exercise_catalog_seeder.dart';
import 'package:forge/domain/entities/forge_request.dart';
import 'package:forge/domain/entities/persist_generated_workout_request.dart';
import 'package:forge/domain/entities/persisted_session_exercise.dart';
import 'package:forge/domain/entities/workout_enums.dart';
import 'package:forge/domain/repositories/exercise_repository.dart';
import 'package:forge/domain/repositories/workout_session_repository.dart';
import 'package:forge/domain/services/forge_engine.dart';
import 'package:forge/domain/services/forge_workout_adaptation_service.dart';
import 'package:forge/domain/services/forge_workout_generator.dart';
import 'package:forge/domain/services/generated_workout_plan_validator.dart';
import 'package:forge/domain/services/workout_validation_service.dart';
import 'package:forge/domain/use_cases/build_forge_adaptation_context.dart';
import 'package:forge/domain/use_cases/generate_adapted_forge_workout.dart';
import 'package:forge/domain/use_cases/generate_forge_workout.dart';
import 'package:forge/domain/use_cases/persist_generated_workout.dart';

import 'workout_test_helpers.dart';

/// Conta le query SQL effettivamente eseguite (Milestone 7.2, sezione 64
/// riformulata): sostituisce l'assert a cronometro reale, sensibile alla
/// contesa di risorse quando l'intera suite gira insieme ad altri test,
/// con un conteggio deterministico — stesso numero di query a ogni
/// esecuzione, su qualsiasi macchina, perché dipende solo dal codice
/// eseguito e dai dati seminati, mai dalla velocità di CPU/IO del momento.
/// Usa la `QueryInterceptor` pubblica di drift (pensata esattamente per
/// intercettare le chiamate a un `QueryExecutor` senza toccarne il
/// comportamento), non un meccanismo interno/fragile.
class _QueryCountInterceptor extends QueryInterceptor {
  int count = 0;

  @override
  Future<List<Map<String, Object?>>> runSelect(
    QueryExecutor executor,
    String statement,
    List<Object?> args,
  ) {
    count++;
    return super.runSelect(executor, statement, args);
  }

  @override
  Future<int> runInsert(
    QueryExecutor executor,
    String statement,
    List<Object?> args,
  ) {
    count++;
    return super.runInsert(executor, statement, args);
  }

  @override
  Future<int> runUpdate(
    QueryExecutor executor,
    String statement,
    List<Object?> args,
  ) {
    count++;
    return super.runUpdate(executor, statement, args);
  }

  @override
  Future<int> runDelete(
    QueryExecutor executor,
    String statement,
    List<Object?> args,
  ) {
    count++;
    return super.runDelete(executor, statement, args);
  }

  @override
  Future<void> runCustom(
    QueryExecutor executor,
    String statement,
    List<Object?> args,
  ) {
    count++;
    return super.runCustom(executor, statement, args);
  }

  @override
  Future<void> runBatched(
    QueryExecutor executor,
    BatchedStatements statements,
  ) {
    count++;
    return super.runBatched(executor, statements);
  }
}

/// Hardening (Milestone 5.6, sezioni 64/65/66): performance dell'adattamento
/// su 100 pipeline consecutive, e matrice rappresentativa sul catalogo reale
/// (tipo × livello × durata × attrezzatura) e sullo storico reale (nessuno/
/// positivo/misto/skip ripetuti/molti abort). Le 500 generazioni di
/// `forge_hardening_determinism_test.dart` già soddisfano la sezione 63
/// (performance della generazione base): qui il focus è l'adattamento e la
/// matrice, non ripetuto lì.
void main() {
  late AppDatabase db;
  late _QueryCountInterceptor queryCounter;
  late ExerciseRepository exerciseRepository;
  late DriftWorkoutRepository workoutRepository;
  late WorkoutSessionRepository sessionRepository;
  late GenerateForgeWorkout generate;
  late GenerateAdaptedForgeWorkout generateAdapted;
  late PersistGeneratedWorkout persist;
  late int profileId;

  setUp(() async {
    queryCounter = _QueryCountInterceptor();
    db = AppDatabase(NativeDatabase.memory().interceptWith(queryCounter));
    final raw = File('assets/data/exercises_v1.json').readAsStringSync();
    await ExerciseCatalogSeeder(db).seedFromString(raw);
    profileId = await insertProfilo(db);

    exerciseRepository = DriftExerciseRepository(db);
    workoutRepository = DriftWorkoutRepository(db);
    sessionRepository = DriftWorkoutSessionRepository(db);

    generate = GenerateForgeWorkout(
      exerciseRepository,
      const ForgeEngine(),
      const ForgeWorkoutGenerator(),
    );
    persist = PersistGeneratedWorkout(
      workoutRepository,
      planValidator: const GeneratedWorkoutPlanValidator(),
      workoutValidationService: const WorkoutValidationService(),
    );
    generateAdapted = GenerateAdaptedForgeWorkout(
      exerciseRepository,
      BuildForgeAdaptationContext(sessionRepository),
      generate,
      const ForgeWorkoutAdaptationService(),
      planValidator: const GeneratedWorkoutPlanValidator(),
    );
  });

  tearDown(() => db.close());

  ForgeRequest request({
    int userLevel = 1,
    Set<String> equipment = const {},
    WorkoutType workoutType = WorkoutType.mobility,
    int targetDurationMinutes = 20,
  }) {
    return ForgeRequest(
      profileId: profileId,
      userLevel: userLevel,
      availableEquipmentCodes: equipment,
      targetDurationMinutes: targetDurationMinutes,
      workoutType: workoutType,
    );
  }

  test('performance adattamento: 100 pipeline GenerateAdaptedForgeWorkout '
      'consecutive con storico reale, nessuna eccezione, risultato coerente '
      'ogni volta (sezione 64)', () async {
    final firstResult = await persist(
      PersistGeneratedWorkoutRequest(
        profileId: profileId,
        generationResult: await generate(request()),
      ),
    );
    expect(firstResult.success, isTrue, reason: '${firstResult.errors}');
    final details = await workoutRepository.getWorkoutDetails(
      firstResult.workoutId!,
    );
    for (var i = 0; i < 5; i++) {
      final startedAt = DateTime(2026, 1, 1 + i, 8);
      final sessionId = await sessionRepository.createSession(
        profileId: profileId,
        details: details!,
        startedAt: startedAt,
      );
      final sessionExercises = await sessionRepository.getSessionExercises(
        sessionId,
      );
      await sessionRepository.updateProgress(
        sessionId: sessionId,
        exercises: [
          for (final e in sessionExercises)
            SessionExerciseProgressUpdate(
              workoutExerciseId: e.workoutExerciseId!,
              completedSets: e.totalSets,
              isSkipped: false,
              isCompleted: true,
            ),
        ],
        updatedAt: startedAt.add(const Duration(minutes: 20)),
      );
      await sessionRepository.completeSession(
        sessionId: sessionId,
        endedAt: startedAt.add(const Duration(minutes: 25)),
      );
    }

    final now = DateTime(2026, 1, 10);
    final perIterationQueryCounts = <int>[];
    var previousQueryCount = queryCounter.count;
    for (var i = 0; i < 100; i++) {
      final result = await generateAdapted(
        request: request(),
        profileId: profileId,
        now: now,
      );
      expect(result.success, isTrue, reason: 'iterazione $i: ${result.errors}');
      final currentQueryCount = queryCounter.count;
      perIterationQueryCounts.add(currentQueryCount - previousQueryCount);
      previousQueryCount = currentQueryCount;
    }

    // Verifica strutturale e deterministica, non a cronometro reale
    // (quest'ultimo, un budget di 2 minuti su `Stopwatch`, falliva sotto
    // la contesa di risorse quando l'intera suite gira in parallelo ad
    // altri test, pur passando sempre in isolamento — mai una regressione
    // di Forge). Le 100 iterazioni lavorano sullo stesso storico fisso (le
    // 5 sessioni seminate sopra) con la stessa richiesta: il numero di
    // query SQL eseguite da ciascuna deve quindi essere **esattamente**
    // lo stesso a ogni esecuzione, su qualsiasi macchina, perché dipende
    // solo dal codice e dai dati seminati — mai dalla velocità di CPU/IO
    // del momento. Un loop o una query N^2 introdotta per errore (la
    // stessa preoccupazione della soglia a cronometro che sostituisce) si
    // manifesterebbe qui come un conteggio diverso tra le iterazioni,
    // individuato in modo esatto invece che probabilistico.
    expect(
      perIterationQueryCounts.first,
      greaterThan(0),
      reason:
          'nessuna query intercettata: il contatore non sta osservando '
          'l\'esecuzione reale (verifica che _QueryCountInterceptor sia '
          'ancora applicato al database di test)',
    );
    final minQueries = perIterationQueryCounts.reduce((a, b) => a < b ? a : b);
    final maxQueries = perIterationQueryCounts.reduce((a, b) => a > b ? a : b);
    expect(
      maxQueries,
      minQueries,
      reason:
          'query per iterazione non costanti: $perIterationQueryCounts '
          '(min $minQueries, max $maxQueries) — una crescita indica una '
          'regressione strutturale (es. query ripetuta senza necessità o '
          'storico riletto per intero a ogni iterazione)',
    );
  });

  test('matrice rappresentativa sul catalogo reale: tipo × livello × durata × '
      'attrezzatura, nessun crash, determinismo, nessun duplicato (sezione '
      '65)', () async {
    const combos = [
      (WorkoutType.fullBody, 1, 20, <String>{}),
      (WorkoutType.upperBody, 2, 30, {'BAND'}),
      (WorkoutType.lowerBody, 3, 40, {'CHAIR'}),
      (WorkoutType.mobility, 4, 50, {'MAT'}),
      (WorkoutType.cardio, 5, 60, {'STEP'}),
      (
        WorkoutType.recovery,
        1,
        30,
        {'CHAIR', 'WALL', 'MAT', 'BAND', 'DUMBBELL', 'STEP'},
      ),
    ];

    for (final (type, level, duration, equipment) in combos) {
      final req = request(
        workoutType: type,
        userLevel: level,
        targetDurationMinutes: duration,
        equipment: equipment,
      );
      final first = await generate(req);
      final second = await generate(req);

      expect(
        second.plan?.exercises.map((e) => e.exercise.code).toList(),
        first.plan?.exercises.map((e) => e.exercise.code).toList(),
        reason: '$type/livello $level/$duration min/$equipment',
      );

      if (first.plan != null) {
        final codes = first.plan!.exercises
            .map((e) => e.exercise.code)
            .toList();
        expect(
          codes.toSet().length,
          codes.length,
          reason: 'nessun duplicato per $type',
        );
        for (final e in first.plan!.exercises) {
          expect(e.exercise.minimumLevel, lessThanOrEqualTo(level));
        }
      } else {
        // Fallimento controllato accettabile: deve comunque spiegarsi.
        expect(
          first.errors,
          isNotEmpty,
          reason: '$type senza piano ma senza errore',
        );
      }
    }
  });

  test(
    'matrice storico reale: nessuno/positivo/misto/skip ripetuti/molti '
    'abort -> adattamento sempre coerente, mai un\'eccezione (sezione 66)',
    () async {
      Future<int> seedWorkout() async {
        final result = await persist(
          PersistGeneratedWorkoutRequest(
            profileId: profileId,
            generationResult: await generate(request()),
          ),
        );
        expect(result.success, isTrue, reason: '${result.errors}');
        return result.workoutId!;
      }

      Future<void> simulateSession({
        required int workoutId,
        required DateTime startedAt,
        required bool complete,
        required bool skipAll,
      }) async {
        final details = await workoutRepository.getWorkoutDetails(workoutId);
        final sessionId = await sessionRepository.createSession(
          profileId: profileId,
          details: details!,
          startedAt: startedAt,
        );
        final sessionExercises = await sessionRepository.getSessionExercises(
          sessionId,
        );
        await sessionRepository.updateProgress(
          sessionId: sessionId,
          exercises: [
            for (final e in sessionExercises)
              SessionExerciseProgressUpdate(
                workoutExerciseId: e.workoutExerciseId!,
                completedSets: skipAll ? 0 : e.totalSets,
                isSkipped: skipAll,
                isCompleted: !skipAll,
              ),
          ],
          updatedAt: startedAt.add(const Duration(minutes: 10)),
        );
        if (complete) {
          await sessionRepository.completeSession(
            sessionId: sessionId,
            endedAt: startedAt.add(const Duration(minutes: 20)),
          );
        } else {
          await sessionRepository.abortSession(
            sessionId: sessionId,
            endedAt: startedAt.add(const Duration(minutes: 5)),
          );
        }
      }

      final now = DateTime(2026, 2, 1);

      // 1) nessuno storico -> maintain.
      final noHistoryId = await seedWorkout();
      final noHistory = await generateAdapted(
        request: request(),
        profileId: profileId,
        now: now,
      );
      expect(noHistory.success, isTrue);
      // 2) storico positivo (5 completate, tutte le serie) -> progress.
      for (var i = 0; i < 5; i++) {
        await simulateSession(
          workoutId: noHistoryId,
          startedAt: DateTime(2026, 1, 1 + i, 8),
          complete: true,
          skipAll: false,
        );
      }
      final positive = await generateAdapted(
        request: request(),
        profileId: profileId,
        now: now,
      );
      expect(positive.success, isTrue);

      // 3) storico misto (alternanza completo/abort) su una nuova scheda.
      final mixedWorkoutId = await seedWorkout();
      for (var i = 0; i < 4; i++) {
        await simulateSession(
          workoutId: mixedWorkoutId,
          startedAt: DateTime(2026, 3, 1 + i, 8),
          complete: i.isEven,
          skipAll: false,
        );
      }
      final mixed = await generateAdapted(
        request: request(),
        profileId: profileId,
        now: DateTime(2026, 3, 10),
      );
      expect(mixed.success, isTrue);

      // 4) skip ripetuti.
      final skipWorkoutId = await seedWorkout();
      for (var i = 0; i < 4; i++) {
        await simulateSession(
          workoutId: skipWorkoutId,
          startedAt: DateTime(2026, 4, 1 + i, 8),
          complete: true,
          skipAll: true,
        );
      }
      final repeatedSkip = await generateAdapted(
        request: request(),
        profileId: profileId,
        now: DateTime(2026, 4, 10),
      );
      expect(repeatedSkip.success, isTrue);

      // 5) molte sessioni interrotte.
      final abortWorkoutId = await seedWorkout();
      for (var i = 0; i < 5; i++) {
        await simulateSession(
          workoutId: abortWorkoutId,
          startedAt: DateTime(2026, 5, 1 + i, 8),
          complete: false,
          skipAll: false,
        );
      }
      final abortedHeavy = await generateAdapted(
        request: request(),
        profileId: profileId,
        now: DateTime(2026, 5, 10),
      );
      expect(abortedHeavy.success, isTrue);
    },
  );
}
