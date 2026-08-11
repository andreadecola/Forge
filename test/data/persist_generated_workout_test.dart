import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/data/database/app_database.dart';
import 'package:forge/data/repositories/drift_workout_repository.dart';
import 'package:forge/domain/entities/forge_composition_reason.dart';
import 'package:forge/domain/entities/forge_evaluation_result.dart';
import 'package:forge/domain/entities/forge_generation_error.dart';
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

ForgeRequest _request({
  int profileId = 1,
  int userLevel = 1,
  int targetDurationMinutes = 30,
  WorkoutType workoutType = WorkoutType.fullBody,
}) {
  return ForgeRequest(
    profileId: profileId,
    userLevel: userLevel,
    availableEquipmentCodes: const {},
    targetDurationMinutes: targetDurationMinutes,
    workoutType: workoutType,
  );
}

GeneratedWorkoutExercise _entry({
  required int exerciseId,
  required String code,
  required int order,
  int estimatedDurationSeconds = 40,
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
    estimatedDurationSeconds: estimatedDurationSeconds,
    score: const ForgeScore(total: 0.8, components: [], reasons: []),
    decisionReasons: const [],
  );
}

GeneratedWorkoutPlan _plan({
  required List<GeneratedWorkoutExercise> exercises,
  required ForgeRequest request,
  bool isComplete = true,
  List<ForgeGenerationWarning> warnings = const [],
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
    warnings: warnings,
    decisionReasons: const [
      ForgeCompositionReason(
        code: ForgeCompositionReasonCode.coverageSatisfied,
      ),
    ],
    isComplete: isComplete,
  );
}

ForgeEvaluationResult _dummyEvaluation(ForgeRequest request) {
  return ForgeEvaluationResult(
    normalizedRequest: request,
    eligible: const [],
    excluded: const [],
  );
}

ForgeGenerationResult _success(GeneratedWorkoutPlan plan) {
  return ForgeGenerationResult(
    plan: plan,
    errors: const [],
    warnings: plan.warnings,
    evaluation: _dummyEvaluation(plan.request),
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

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    repository = DriftWorkoutRepository(database);
    useCase = PersistGeneratedWorkout(repository);
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
    exerciseCId = await insertEsercizio(
      database,
      codice: 'A-003',
      idCategoria: categoryId,
      defaultReps: 10,
    );
  });

  tearDown(() => database.close());

  test('piano valido a 3 esercizi -> Workout READY/FORGE_ENGINE persistito '
      'con tipo, livello, durata, ordine e parametri coerenti', () async {
    final request = _request(profileId: profileId, targetDurationMinutes: 3);
    final plan = _plan(
      request: request,
      exercises: [
        _entry(exerciseId: exerciseAId, code: 'A-001', order: 1),
        _entry(exerciseId: exerciseBId, code: 'A-002', order: 2),
        _entry(exerciseId: exerciseCId, code: 'A-003', order: 3),
      ],
    );

    final result = await useCase(
      PersistGeneratedWorkoutRequest(
        profileId: profileId,
        generationResult: _success(plan),
      ),
    );

    expect(result.success, isTrue, reason: '${result.errors}');
    expect(result.workoutId, isNotNull);

    final details = await repository.getWorkoutDetails(result.workoutId!);
    expect(details, isNotNull);
    expect(details!.workout.type, WorkoutType.fullBody);
    expect(details.workout.level, request.userLevel);
    expect(details.workout.status, WorkoutDefinitionStatus.ready);
    expect(details.workout.origin, WorkoutOrigin.forgeEngine);
    expect(details.workout.profileId, profileId);
    expect(details.exercises, hasLength(3));
    expect(details.exercises.map((e) => e.workoutExercise.order).toList(), [
      1,
      2,
      3,
    ]);
    for (final entry in details.exercises) {
      expect(entry.workoutExercise.repetitions, 10);
      expect(entry.workoutExercise.restSeconds, 30);
      expect(entry.workoutExercise.workoutId, result.workoutId);
    }
  });

  test('arrotondamento durata per eccesso: 3 esercizi da 40s + 2 transizioni '
      'da 10s = 140s -> 3 minuti (ceil), non 2', () async {
    final request = _request(profileId: profileId);
    final plan = _plan(
      request: request,
      exercises: [
        _entry(exerciseId: exerciseAId, code: 'A-001', order: 1),
        _entry(exerciseId: exerciseBId, code: 'A-002', order: 2),
        _entry(exerciseId: exerciseCId, code: 'A-003', order: 3),
      ],
    );
    expect(plan.estimatedDurationSeconds, 140);

    final result = await useCase(
      PersistGeneratedWorkoutRequest(
        profileId: profileId,
        generationResult: _success(plan),
      ),
    );

    final saved = await repository.getWorkoutById(result.workoutId!);
    expect(saved!.estimatedDurationMinutes, 3);
  });

  test(
    'nessun WorkoutExercise persistito con workoutId placeholder 0',
    () async {
      final request = _request(profileId: profileId);
      final plan = _plan(
        request: request,
        exercises: [_entry(exerciseId: exerciseAId, code: 'A-001', order: 1)],
      );

      final result = await useCase(
        PersistGeneratedWorkoutRequest(
          profileId: profileId,
          generationResult: _success(plan),
        ),
      );

      final rows = await database
          .select(database.allenamentiEserciziTable)
          .get();
      expect(rows, isNotEmpty);
      for (final row in rows) {
        expect(row.idAllenamento, isNot(0));
        expect(row.idAllenamento, result.workoutId);
      }
    },
  );

  test(
    'nome default deterministico quando non fornito, ripetuto identico',
    () async {
      final request = _request(profileId: profileId);
      final plan = _plan(
        request: request,
        exercises: [_entry(exerciseId: exerciseAId, code: 'A-001', order: 1)],
      );

      final first = await useCase(
        PersistGeneratedWorkoutRequest(
          profileId: profileId,
          generationResult: _success(plan),
        ),
      );
      final second = await useCase(
        PersistGeneratedWorkoutRequest(
          profileId: profileId,
          generationResult: _success(plan),
        ),
      );

      final firstWorkout = await repository.getWorkoutById(first.workoutId!);
      final secondWorkout = await repository.getWorkoutById(second.workoutId!);
      expect(firstWorkout!.name, 'Forge Full Body');
      expect(secondWorkout!.name, 'Forge Full Body');
      // Due chiamate distinte creano due schede distinte (sezione 32,
      // nessuna deduplica): id diversi nonostante lo stesso nome.
      expect(first.workoutId, isNot(second.workoutId));
    },
  );

  test('nome fornito dal chiamante viene preservato', () async {
    final request = _request(profileId: profileId);
    final plan = _plan(
      request: request,
      exercises: [_entry(exerciseId: exerciseAId, code: 'A-001', order: 1)],
    );

    final result = await useCase(
      PersistGeneratedWorkoutRequest(
        profileId: profileId,
        generationResult: _success(plan),
        name: 'Il mio allenamento',
      ),
    );

    final saved = await repository.getWorkoutById(result.workoutId!);
    expect(saved!.name, 'Il mio allenamento');
  });

  test('ForgeGenerationResult.success == false -> generationFailed, '
      'nessuna scrittura', () async {
    final request = _request(profileId: profileId);
    final failed = ForgeGenerationResult(
      errors: const [ForgeGenerationError.insufficientEligibleExercises],
      warnings: const [],
      evaluation: _dummyEvaluation(request),
    );

    final result = await useCase(
      PersistGeneratedWorkoutRequest(
        profileId: profileId,
        generationResult: failed,
      ),
    );

    expect(result.success, isFalse);
    expect(result.errors, [PersistGeneratedWorkoutError.generationFailed]);
    expect(result.workoutId, isNull);
    expect(await repository.getWorkouts(profileId: profileId), isEmpty);
  });

  test('plan.isComplete == false -> incompletePlan, nessuna scrittura '
      '(mai una bozza automatica)', () async {
    final request = _request(profileId: profileId);
    final plan = _plan(
      request: request,
      exercises: [_entry(exerciseId: exerciseAId, code: 'A-001', order: 1)],
      isComplete: false,
    );

    final result = await useCase(
      PersistGeneratedWorkoutRequest(
        profileId: profileId,
        generationResult: _success(plan),
      ),
    );

    expect(result.success, isFalse);
    expect(result.errors, [PersistGeneratedWorkoutError.incompletePlan]);
    expect(result.workoutId, isNull);
    expect(await repository.getWorkouts(profileId: profileId), isEmpty);
  });

  test('piano con ordine non valido (duplicato) -> invalidGeneratedPlan, '
      'nessuna scrittura', () async {
    final request = _request(profileId: profileId);
    final plan = _plan(
      request: request,
      exercises: [
        _entry(exerciseId: exerciseAId, code: 'A-001', order: 1),
        _entry(exerciseId: exerciseBId, code: 'A-002', order: 1),
      ],
    );

    final result = await useCase(
      PersistGeneratedWorkoutRequest(
        profileId: profileId,
        generationResult: _success(plan),
      ),
    );

    expect(result.success, isFalse);
    expect(result.errors, [PersistGeneratedWorkoutError.invalidGeneratedPlan]);
    expect(await repository.getWorkouts(profileId: profileId), isEmpty);
  });

  test('piano con warning ma altrimenti valido -> persistito, warning '
      'conservati nel risultato', () async {
    final request = _request(profileId: profileId);
    final plan = _plan(
      request: request,
      exercises: [_entry(exerciseId: exerciseAId, code: 'A-001', order: 1)],
      warnings: const [ForgeGenerationWarning.durationBelowTarget],
    );

    final result = await useCase(
      PersistGeneratedWorkoutRequest(
        profileId: profileId,
        generationResult: _success(plan),
      ),
    );

    expect(result.success, isTrue);
    expect(result.workoutId, isNotNull);
    expect(result.warnings, [ForgeGenerationWarning.durationBelowTarget]);
  });

  test(
    'atomicità: un exerciseId inesistente nel piano fa fallire l\'intera '
    'transazione -> nessun Workout e nessun WorkoutExercise residuo',
    () async {
      const nonExistentExerciseId = 999999;
      final request = _request(profileId: profileId);
      final plan = _plan(
        request: request,
        exercises: [
          _entry(exerciseId: exerciseAId, code: 'A-001', order: 1),
          _entry(exerciseId: exerciseBId, code: 'A-002', order: 2),
          _entry(exerciseId: nonExistentExerciseId, code: 'A-999', order: 3),
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
      expect(result.workoutId, isNull);

      final workouts = await database.select(database.allenamentiTable).get();
      expect(workouts, isEmpty);
      final exerciseRows = await database
          .select(database.allenamentiEserciziTable)
          .get();
      expect(exerciseRows, isEmpty);
    },
  );
}
