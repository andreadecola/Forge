import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/data/database/app_database.dart';
import 'package:forge/data/repositories/drift_exercise_repository.dart';
import 'package:forge/data/repositories/drift_workout_repository.dart';
import 'package:forge/data/repositories/drift_workout_session_repository.dart';
import 'package:forge/data/seed/exercise_catalog_seeder.dart';
import 'package:forge/domain/entities/forge_adaptation_decision.dart';
import 'package:forge/domain/entities/forge_exercise_adaptation_action.dart';
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

/// Test di integrazione end-to-end (Milestone 5.4, sezione 63/64/65):
/// catalogo reale seedato, profilo reale, un allenamento Forge persistito
/// (Milestone 5.3), sessioni realistiche create nel database (Milestone
/// 4.4.3), contesto di adattamento costruito dallo storico reale, e un
/// nuovo piano generato e adattato.
void main() {
  late AppDatabase db;
  late ExerciseRepository exerciseRepository;
  late DriftWorkoutRepository workoutRepository;
  late WorkoutSessionRepository sessionRepository;
  late PersistGeneratedWorkout persist;
  late GenerateForgeWorkout generate;
  late GenerateAdaptedForgeWorkout generateAdapted;
  late int profileId;

  ForgeRequest request() {
    return ForgeRequest(
      profileId: profileId,
      userLevel: 1,
      availableEquipmentCodes: const {'CHAIR'},
      targetDurationMinutes: 20,
      workoutType: WorkoutType.mobility,
    );
  }

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

  test('catalogo reale, nessuna sessione -> maintain, piano identico alla '
      'generazione base della Milestone 5.2 (sezione 65)', () async {
    final base = await generate(request());
    final adapted = await generateAdapted(
      request: request(),
      profileId: profileId,
      now: DateTime(2026, 6, 1),
    );

    expect(adapted.success, isTrue, reason: '${adapted.errors}');
    expect(adapted.plan!.decision, ForgeAdaptationDecision.maintain);
    expect(
      adapted.plan!.plan.exercises.map((e) => e.exercise.code).toList(),
      base.plan!.exercises.map((e) => e.exercise.code).toList(),
    );
    expect(
      adapted.plan!.plan.exercises
          .map((e) => e.workoutExercise.repetitions)
          .toList(),
      base.plan!.exercises.map((e) => e.workoutExercise.repetitions).toList(),
    );
  });

  test('storico reale con alta completion -> progress; se un esercizio '
      'viene progredito, il target proviene realmente da una relazione '
      'del catalogo (sezione 21/64)', () async {
    // 1. Genera e persiste una prima scheda Forge reale.
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
    expect(details, isNotNull);

    // 2. Simula 5 sessioni reali completate con tutte le serie
    // completate, sufficienti a superare ogni soglia di adattamento.
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

    // 3. Genera un nuovo piano adattato con lo stesso ForgeRequest.
    final adapted = await generateAdapted(
      request: request(),
      profileId: profileId,
      now: DateTime(2026, 1, 10),
    );

    expect(adapted.success, isTrue, reason: '${adapted.errors}');
    expect(adapted.plan!.decision, ForgeAdaptationDecision.progress);

    final progressed = adapted.plan!.exerciseDecisions.where(
      (d) => d.action == ForgeExerciseAdaptationAction.progress,
    );
    for (final decision in progressed) {
      final progressions = await exerciseRepository.getProgressions(
        decision.sourceExerciseId,
      );
      expect(
        progressions.map((p) => p.target.id),
        contains(decision.targetExerciseId),
        reason:
            'il target deve provenire realmente da progressioni_esercizi, '
            'mai inventato',
      );
    }
  });

  test('determinismo: stessa richiesta e stesso storico -> stesso piano '
      'adattato, anche ripetuto (sezione 61)', () async {
    final firstResult = await persist(
      PersistGeneratedWorkoutRequest(
        profileId: profileId,
        generationResult: await generate(request()),
      ),
    );
    final details = await workoutRepository.getWorkoutDetails(
      firstResult.workoutId!,
    );
    for (var i = 0; i < 4; i++) {
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
        updatedAt: startedAt,
      );
      await sessionRepository.completeSession(
        sessionId: sessionId,
        endedAt: startedAt.add(const Duration(minutes: 20)),
      );
    }

    final now = DateTime(2026, 1, 10);
    final first = await generateAdapted(
      request: request(),
      profileId: profileId,
      now: now,
    );
    for (var i = 0; i < 5; i++) {
      final result = await generateAdapted(
        request: request(),
        profileId: profileId,
        now: now,
      );
      expect(
        result.plan!.plan.exercises.map((e) => e.exercise.code).toList(),
        first.plan!.plan.exercises.map((e) => e.exercise.code).toList(),
      );
      expect(
        result.plan!.plan.exercises
            .map((e) => e.workoutExercise.repetitions)
            .toList(),
        first.plan!.plan.exercises
            .map((e) => e.workoutExercise.repetitions)
            .toList(),
      );
      expect(result.plan!.decision, first.plan!.decision);
    }
  });
}
