import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/data/database/app_database.dart';
import 'package:forge/data/repositories/drift_workout_repository.dart';
import 'package:forge/domain/entities/forge_composition_reason.dart';
import 'package:forge/domain/entities/forge_evaluation_result.dart';
import 'package:forge/domain/entities/forge_generation_result.dart';
import 'package:forge/domain/entities/forge_generation_warning.dart';
import 'package:forge/domain/entities/forge_request.dart';
import 'package:forge/domain/entities/forge_score.dart';
import 'package:forge/domain/entities/generated_workout_exercise.dart';
import 'package:forge/domain/entities/generated_workout_plan.dart';
import 'package:forge/domain/entities/persist_generated_workout_error.dart';
import 'package:forge/domain/entities/persist_generated_workout_request.dart';
import 'package:forge/domain/entities/workout_enums.dart';
import 'package:forge/domain/entities/workout_exercise.dart';
import 'package:forge/domain/use_cases/persist_generated_workout.dart';

import '../domain/forge_fixtures.dart';
import 'workout_test_helpers.dart';

/// Hardening (Milestone 5.6, sezioni 42/44): stress dell'atomicità di
/// `PersistGeneratedWorkout` con il vincolo non valido in prima, in mezzo e
/// in ultima posizione del piano (la Milestone 5.3 aveva già verificato
/// solo l'ultima posizione), piu' un `profileId` inesistente — mai un
/// Workout parziale in nessuno dei due casi.
ForgeRequest _request({required int profileId}) {
  return ForgeRequest(
    profileId: profileId,
    userLevel: 1,
    availableEquipmentCodes: const {},
    targetDurationMinutes: 30,
    workoutType: WorkoutType.fullBody,
  );
}

GeneratedWorkoutExercise _entry({
  required int exerciseId,
  required String code,
  required int order,
}) {
  return GeneratedWorkoutExercise(
    workoutExercise: WorkoutExercise(
      workoutId: GeneratedWorkoutExercise.placeholderWorkoutId,
      exerciseId: exerciseId,
      order: order,
      repetitions: 10,
      restSeconds: 30,
    ),
    exercise: buildExercise(id: exerciseId, code: code, defaultReps: 10),
    estimatedDurationSeconds: 40,
    score: const ForgeScore(total: 0.8, components: [], reasons: []),
    decisionReasons: const [],
  );
}

GeneratedWorkoutPlan _plan({
  required List<GeneratedWorkoutExercise> exercises,
  required ForgeRequest request,
}) {
  final total =
      exercises.fold<int>(0, (a, e) => a + e.estimatedDurationSeconds) +
      (exercises.isEmpty ? 0 : (exercises.length - 1) * 10);
  return GeneratedWorkoutPlan(
    request: request,
    workoutType: request.workoutType,
    targetDurationMinutes: request.targetDurationMinutes,
    estimatedDurationSeconds: total,
    exercises: exercises,
    warnings: const [ForgeGenerationWarning.durationBelowTarget],
    decisionReasons: const [
      ForgeCompositionReason(
        code: ForgeCompositionReasonCode.coverageSatisfied,
      ),
    ],
    isComplete: true,
  );
}

ForgeGenerationResult _success(GeneratedWorkoutPlan plan) {
  return ForgeGenerationResult(
    plan: plan,
    errors: const [],
    warnings: plan.warnings,
    evaluation: ForgeEvaluationResult(
      normalizedRequest: plan.request,
      eligible: const [],
      excluded: const [],
    ),
  );
}

void main() {
  late AppDatabase database;
  late DriftWorkoutRepository repository;
  late PersistGeneratedWorkout useCase;
  late int profileId;
  late int categoryId;
  late int exerciseAId;
  late int exerciseBId;
  late int exerciseCId;
  const nonExistentExerciseId = 999999;

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    repository = DriftWorkoutRepository(database);
    useCase = PersistGeneratedWorkout(repository);
    profileId = await insertProfilo(database);
    categoryId = await insertCategoria(database);
    exerciseAId = await insertEsercizio(
      database,
      codice: 'H-001',
      idCategoria: categoryId,
      defaultReps: 10,
    );
    exerciseBId = await insertEsercizio(
      database,
      codice: 'H-002',
      idCategoria: categoryId,
      defaultReps: 10,
    );
    exerciseCId = await insertEsercizio(
      database,
      codice: 'H-003',
      idCategoria: categoryId,
      defaultReps: 10,
    );
  });

  tearDown(() => database.close());

  Future<void> expectZeroResidualRows() async {
    final workouts = await database.select(database.allenamentiTable).get();
    expect(workouts, isEmpty);
    final exerciseRows = await database
        .select(database.allenamentiEserciziTable)
        .get();
    expect(exerciseRows, isEmpty);
  }

  test(
    'atomicità: exerciseId inesistente in PRIMA posizione -> nessun residuo',
    () async {
      final request = _request(profileId: profileId);
      final plan = _plan(
        request: request,
        exercises: [
          _entry(exerciseId: nonExistentExerciseId, code: 'H-999', order: 1),
          _entry(exerciseId: exerciseAId, code: 'H-001', order: 2),
          _entry(exerciseId: exerciseBId, code: 'H-002', order: 3),
        ],
      );

      final result = await useCase(
        PersistGeneratedWorkoutRequest(
          profileId: profileId,
          generationResult: _success(plan),
        ),
      );

      expect(result.success, isFalse);
      expect(result.errors, [PersistGeneratedWorkoutError.persistenceFailed]);
      await expectZeroResidualRows();
    },
  );

  test('atomicità: exerciseId inesistente in posizione INTERMEDIA (3 di 4) -> '
      'nessun residuo', () async {
    final request = _request(profileId: profileId);
    final plan = _plan(
      request: request,
      exercises: [
        _entry(exerciseId: exerciseAId, code: 'H-001', order: 1),
        _entry(exerciseId: exerciseBId, code: 'H-002', order: 2),
        _entry(exerciseId: nonExistentExerciseId, code: 'H-999', order: 3),
        _entry(exerciseId: exerciseCId, code: 'H-003', order: 4),
      ],
    );

    final result = await useCase(
      PersistGeneratedWorkoutRequest(
        profileId: profileId,
        generationResult: _success(plan),
      ),
    );

    expect(result.success, isFalse);
    expect(result.errors, [PersistGeneratedWorkoutError.persistenceFailed]);
    await expectZeroResidualRows();
  });

  test(
    'atomicità: exerciseId inesistente in ULTIMA posizione -> nessun '
    'residuo (regressione dal test già esistente della Milestone 5.3)',
    () async {
      final request = _request(profileId: profileId);
      final plan = _plan(
        request: request,
        exercises: [
          _entry(exerciseId: exerciseAId, code: 'H-001', order: 1),
          _entry(exerciseId: exerciseBId, code: 'H-002', order: 2),
          _entry(exerciseId: nonExistentExerciseId, code: 'H-999', order: 3),
        ],
      );

      final result = await useCase(
        PersistGeneratedWorkoutRequest(
          profileId: profileId,
          generationResult: _success(plan),
        ),
      );

      expect(result.success, isFalse);
      expect(result.errors, [PersistGeneratedWorkoutError.persistenceFailed]);
      await expectZeroResidualRows();
    },
  );

  test('profileId inesistente: nessuna riga in user_profiles -> violazione FK, '
      'fallimento controllato, nessun residuo (sezione 44)', () async {
    const nonExistentProfileId = 888888;
    final request = _request(profileId: nonExistentProfileId);
    final plan = _plan(
      request: request,
      exercises: [
        _entry(exerciseId: exerciseAId, code: 'H-001', order: 1),
        _entry(exerciseId: exerciseBId, code: 'H-002', order: 2),
      ],
    );

    final result = await useCase(
      PersistGeneratedWorkoutRequest(
        profileId: nonExistentProfileId,
        generationResult: _success(plan),
      ),
    );

    expect(result.success, isFalse);
    expect(result.errors, [PersistGeneratedWorkoutError.persistenceFailed]);
    await expectZeroResidualRows();
  });

  test('piano con warning persistito con successo, warning preservato (sezione '
      '46 — già coperto in Milestone 5.3, riverificato qui su un piano piu\' '
      'grande insieme all\'origin/status)', () async {
    final request = _request(profileId: profileId);
    final plan = _plan(
      request: request,
      exercises: [
        _entry(exerciseId: exerciseAId, code: 'H-001', order: 1),
        _entry(exerciseId: exerciseBId, code: 'H-002', order: 2),
        _entry(exerciseId: exerciseCId, code: 'H-003', order: 3),
      ],
    );

    final result = await useCase(
      PersistGeneratedWorkoutRequest(
        profileId: profileId,
        generationResult: _success(plan),
      ),
    );

    expect(result.success, isTrue);
    expect(result.warnings, [ForgeGenerationWarning.durationBelowTarget]);
    final details = await repository.getWorkoutDetails(result.workoutId!);
    expect(details!.workout.origin, WorkoutOrigin.forgeEngine);
    expect(details.workout.status, WorkoutDefinitionStatus.ready);
    expect(details.exercises.length, 3);
  });
}
