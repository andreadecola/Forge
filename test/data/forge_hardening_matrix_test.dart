import 'dart:io';

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

/// Hardening (Milestone 5.6, sezioni 64/65/66): performance dell'adattamento
/// su 100 pipeline consecutive, e matrice rappresentativa sul catalogo reale
/// (tipo × livello × durata × attrezzatura) e sullo storico reale (nessuno/
/// positivo/misto/skip ripetuti/molti abort). Le 500 generazioni di
/// `forge_hardening_determinism_test.dart` già soddisfano la sezione 63
/// (performance della generazione base): qui il focus è l'adattamento e la
/// matrice, non ripetuto lì.
void main() {
  late AppDatabase db;
  late ExerciseRepository exerciseRepository;
  late DriftWorkoutRepository workoutRepository;
  late WorkoutSessionRepository sessionRepository;
  late GenerateForgeWorkout generate;
  late GenerateAdaptedForgeWorkout generateAdapted;
  late PersistGeneratedWorkout persist;
  late int profileId;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
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
    final stopwatch = Stopwatch()..start();
    for (var i = 0; i < 100; i++) {
      final result = await generateAdapted(
        request: request(),
        profileId: profileId,
        now: now,
      );
      expect(result.success, isTrue, reason: 'iterazione $i: ${result.errors}');
    }
    stopwatch.stop();
    // Nessuna soglia rigida in millisecondi (richiesto esplicitamente di
    // evitarla): solo un limite largo per intercettare una regressione
    // grave (es. loop o query N^2 introdotta per errore).
    expect(stopwatch.elapsed, lessThan(const Duration(minutes: 2)));
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
