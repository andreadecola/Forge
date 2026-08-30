import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/data/database/app_database.dart';
import 'package:forge/data/repositories/drift_planned_activity_repository.dart';
import 'package:forge/data/repositories/drift_workout_repository.dart';
import 'package:forge/data/repositories/weekly_plan_generation_repository.dart';
import 'package:forge/domain/entities/adapted_generated_workout_plan.dart';
import 'package:forge/domain/entities/forge_adaptation_decision.dart';
import 'package:forge/domain/entities/forge_adapted_generation_result.dart';
import 'package:forge/domain/entities/forge_composition_reason.dart';
import 'package:forge/domain/entities/forge_evaluation_result.dart';
import 'package:forge/domain/entities/forge_request.dart';
import 'package:forge/domain/entities/forge_score.dart';
import 'package:forge/domain/entities/generated_workout_exercise.dart';
import 'package:forge/domain/entities/generated_workout_plan.dart';
import 'package:forge/domain/entities/planned_activity_enums.dart';
import 'package:forge/domain/entities/weekly_plan_generation_proposal.dart';
import 'package:forge/domain/entities/workout_enums.dart';
import 'package:forge/domain/entities/workout_exercise.dart';

import '../domain/forge_fixtures.dart';
import 'workout_test_helpers.dart';

/// Test di atomicità di [WeeklyPlanGenerationRepository] (Milestone 8.4,
/// sezione 27/28/75): non usa il Forge Engine reale (nessun catalogo
/// seedato) — costruisce `AdaptedGeneratedWorkoutPlan` a mano, stesso stile
/// di `persist_generated_workout_test.dart`, per isolare la sola logica di
/// persistenza/transazione dall'algoritmo del motore (già testato altrove).
void main() {
  late AppDatabase database;
  late int profileId;
  late int categoryId;
  late int exerciseAId;
  late int exerciseBId;

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    profileId = await insertProfilo(database);
    categoryId = await insertCategoria(database);
    exerciseAId = await insertEsercizio(
      database,
      codice: 'A-001',
      idCategoria: categoryId,
      defaultReps: 10,
    );
    exerciseBId = await insertEsercizio(
      database,
      codice: 'A-002',
      idCategoria: categoryId,
      defaultReps: 10,
    );
  });

  tearDown(() => database.close());

  ForgeRequest request() {
    return ForgeRequest(
      profileId: profileId,
      userLevel: 1,
      availableEquipmentCodes: const {},
      targetDurationMinutes: 30,
      workoutType: WorkoutType.fullBody,
    );
  }

  ForgeEvaluationResult evaluation(ForgeRequest req) {
    return ForgeEvaluationResult(
      normalizedRequest: req,
      eligible: const [],
      excluded: const [],
    );
  }

  GeneratedWorkoutExercise exerciseEntry({
    required int exerciseId,
    required String code,
  }) {
    return GeneratedWorkoutExercise(
      workoutExercise: WorkoutExercise(
        workoutId: GeneratedWorkoutExercise.placeholderWorkoutId,
        exerciseId: exerciseId,
        order: 1,
        repetitions: 10,
        restSeconds: 30,
      ),
      exercise: buildExercise(id: exerciseId, code: code, defaultReps: 10),
      estimatedDurationSeconds: 40,
      score: const ForgeScore(total: 0.8, components: [], reasons: []),
      decisionReasons: const [],
    );
  }

  /// Un piano adattato "riuscito" che referenzia [exerciseId] — se
  /// [exerciseId] non esiste realmente nella tabella esercizi, la
  /// persistenza fallirà per violazione FK (usato dal test di rollback).
  ForgeAdaptedGenerationResult successfulResult({
    required int exerciseId,
    required String code,
  }) {
    final req = request();
    final plan = GeneratedWorkoutPlan(
      request: req,
      workoutType: req.workoutType,
      targetDurationMinutes: req.targetDurationMinutes,
      estimatedDurationSeconds: 40,
      exercises: [exerciseEntry(exerciseId: exerciseId, code: code)],
      warnings: const [],
      decisionReasons: const [
        ForgeCompositionReason(
          code: ForgeCompositionReasonCode.coverageSatisfied,
        ),
      ],
      isComplete: true,
    );
    return ForgeAdaptedGenerationResult(
      plan: AdaptedGeneratedWorkoutPlan(
        plan: plan,
        decision: ForgeAdaptationDecision.maintain,
        exerciseDecisions: const [],
      ),
      errors: const [],
      warnings: const [],
      evaluation: evaluation(req),
    );
  }

  test('3 voci valide -> 3 Workout READY/FORGE_ENGINE + 3 PlannedActivity, '
      'ognuna sul giorno assegnato', () async {
    final repository = WeeklyPlanGenerationRepository(database);
    final days = [
      DateTime(2026, 8, 24),
      DateTime(2026, 8, 26),
      DateTime(2026, 8, 28),
    ];
    final proposal = WeeklyPlanGenerationProposal(
      weekStart: days.first,
      weekEnd: DateTime(2026, 8, 30),
      entries: [
        for (final day in days)
          ProposedForgeWorkout(
            scheduledDate: day,
            generationResult: successfulResult(
              exerciseId: exerciseAId,
              code: 'A-001',
            ),
          ),
      ],
    );

    final activityIds = await repository.confirmProposal(
      profileId: profileId,
      proposal: proposal,
    );

    expect(activityIds, hasLength(3));

    final plannedActivityRepository = DriftPlannedActivityRepository(
      database.attivitaPianificateDao,
    );
    final workoutRepository = DriftWorkoutRepository(database);
    final createdWorkoutIds = <int>{};
    for (var i = 0; i < activityIds.length; i++) {
      final activity = await plannedActivityRepository.getById(activityIds[i]);
      expect(activity, isNotNull);
      expect(activity!.scheduledDate, days[i]);
      expect(activity.type, PlannedActivityType.workout);
      expect(activity.origin, PlannedActivityOrigin.forgeEngine);
      expect(activity.workoutId, isNotNull);
      createdWorkoutIds.add(activity.workoutId!);

      final workout = await workoutRepository.getWorkoutById(
        activity.workoutId!,
      );
      expect(workout, isNotNull);
      expect(workout!.status, WorkoutDefinitionStatus.ready);
      expect(workout.origin, WorkoutOrigin.forgeEngine);
    }
    // Ogni voce ha creato un Workout distinto: nessuna condivisione
    // accidentale della stessa scheda tra giorni diversi.
    expect(createdWorkoutIds, hasLength(3));

    final walks = await database.camminateDao.getByProfile(profileId);
    expect(walks, isEmpty);
  });

  test(
    'fallimento a metà lista (2 valide + 1 con exerciseId inesistente) -> '
    'rollback completo, zero Workout e zero PlannedActivity residui',
    () async {
      final repository = WeeklyPlanGenerationRepository(database);
      const nonExistentExerciseId = 999999;
      final proposal = WeeklyPlanGenerationProposal(
        weekStart: DateTime(2026, 8, 24),
        weekEnd: DateTime(2026, 8, 30),
        entries: [
          ProposedForgeWorkout(
            scheduledDate: DateTime(2026, 8, 24),
            generationResult: successfulResult(
              exerciseId: exerciseAId,
              code: 'A-001',
            ),
          ),
          ProposedForgeWorkout(
            scheduledDate: DateTime(2026, 8, 26),
            generationResult: successfulResult(
              exerciseId: exerciseBId,
              code: 'A-002',
            ),
          ),
          ProposedForgeWorkout(
            scheduledDate: DateTime(2026, 8, 28),
            generationResult: successfulResult(
              exerciseId: nonExistentExerciseId,
              code: 'A-999',
            ),
          ),
        ],
      );

      await expectLater(
        repository.confirmProposal(profileId: profileId, proposal: proposal),
        throwsA(isA<WeeklyPlanGenerationPersistException>()),
      );

      final workoutRepository = DriftWorkoutRepository(database);
      final allWorkouts = await workoutRepository.getWorkouts(
        profileId: profileId,
      );
      expect(
        allWorkouts,
        isEmpty,
        reason:
            'le prime due voci valide non devono restare persistite se la '
            'terza fallisce',
      );

      final plannedActivityRepository = DriftPlannedActivityRepository(
        database.attivitaPianificateDao,
      );
      final activities = await plannedActivityRepository.getForWeek(
        profileId: profileId,
        weekStart: DateTime(2026, 8, 24),
        weekEnd: DateTime(2026, 8, 30),
      );
      expect(activities, isEmpty);
    },
  );

  test(
    'determinismo/ripetibilità: eseguire la conferma due volte su due '
    'proposte equivalenti produce lo stesso numero di righe ogni volta',
    (() async {
      final repository = WeeklyPlanGenerationRepository(database);
      Future<int> confirmOne(DateTime day) async {
        final ids = await repository.confirmProposal(
          profileId: profileId,
          proposal: WeeklyPlanGenerationProposal(
            weekStart: DateTime(2026, 8, 24),
            weekEnd: DateTime(2026, 8, 30),
            entries: [
              ProposedForgeWorkout(
                scheduledDate: day,
                generationResult: successfulResult(
                  exerciseId: exerciseAId,
                  code: 'A-001',
                ),
              ),
            ],
          ),
        );
        return ids.length;
      }

      expect(await confirmOne(DateTime(2026, 8, 24)), 1);
      expect(await confirmOne(DateTime(2026, 8, 25)), 1);
    }),
  );
}
