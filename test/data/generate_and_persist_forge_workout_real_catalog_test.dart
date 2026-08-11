import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/data/database/app_database.dart';
import 'package:forge/data/repositories/drift_exercise_repository.dart';
import 'package:forge/data/repositories/drift_workout_repository.dart';
import 'package:forge/data/seed/exercise_catalog_seeder.dart';
import 'package:forge/domain/entities/forge_request.dart';
import 'package:forge/domain/entities/generate_and_persist_forge_workout_request.dart';
import 'package:forge/domain/entities/workout_enums.dart';
import 'package:forge/domain/services/forge_engine.dart';
import 'package:forge/domain/services/forge_workout_generator.dart';
import 'package:forge/domain/services/generated_workout_plan_validator.dart';
import 'package:forge/domain/services/workout_validation_service.dart';
import 'package:forge/domain/use_cases/generate_and_persist_forge_workout.dart';
import 'package:forge/domain/use_cases/generate_forge_workout.dart';
import 'package:forge/domain/use_cases/persist_generated_workout.dart';

import 'workout_test_helpers.dart';

/// Test di integrazione end-to-end (Milestone 5.3, sezione 52/53):
/// `ForgeRequest` reale -> `GenerateForgeWorkout` -> `GeneratedWorkoutPlan`
/// -> `PersistGeneratedWorkout` -> `getWorkoutDetails`, sul catalogo reale
/// seedato (118 esercizi), per più `WorkoutType`.
void main() {
  late AppDatabase db;
  late DriftWorkoutRepository workoutRepository;
  late GenerateAndPersistForgeWorkout useCase;
  late int profileId;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    final raw = File('assets/data/exercises_v1.json').readAsStringSync();
    await ExerciseCatalogSeeder(db).seedFromString(raw);
    profileId = await insertProfilo(db);
    final exerciseRepository = DriftExerciseRepository(db);
    workoutRepository = DriftWorkoutRepository(db);

    final generate = GenerateForgeWorkout(
      exerciseRepository,
      const ForgeEngine(),
      const ForgeWorkoutGenerator(),
    );
    final persist = PersistGeneratedWorkout(
      workoutRepository,
      planValidator: const GeneratedWorkoutPlanValidator(),
      workoutValidationService: const WorkoutValidationService(),
    );
    useCase = GenerateAndPersistForgeWorkout(generate, persist);
  });

  tearDown(() => db.close());

  ForgeRequest request({
    int userLevel = 1,
    Set<String> equipment = const {},
    WorkoutType workoutType = WorkoutType.fullBody,
    int targetDurationMinutes = 30,
  }) {
    return ForgeRequest(
      profileId: 1,
      userLevel: userLevel,
      availableEquipmentCodes: equipment,
      targetDurationMinutes: targetDurationMinutes,
      workoutType: workoutType,
    );
  }

  test(
    'end-to-end: livello 1, FULL_BODY, nessuna attrezzatura -> scheda '
    'persistita READY/FORGE_ENGINE, coerente con il piano generato',
    () async {
      final result = await useCase(
        GenerateAndPersistForgeWorkoutRequest(
          forgeRequest: request(),
          profileId: profileId,
        ),
      );

      expect(result.success, isTrue, reason: '${result.errors}');
      expect(result.workoutId, isNotNull);

      final details = await workoutRepository.getWorkoutDetails(
        result.workoutId!,
      );
      expect(details, isNotNull);
      expect(details!.workout.origin, WorkoutOrigin.forgeEngine);
      expect(details.workout.status, WorkoutDefinitionStatus.ready);
      expect(details.workout.profileId, profileId);
      expect(details.workout.type, WorkoutType.fullBody);
      expect(details.exercises, isNotEmpty);

      final codes = details.exercises.map((e) => e.exercise.code).toList();
      expect(codes.toSet().length, codes.length);
      expect(
        details.exercises.map((e) => e.workoutExercise.order).toList(),
        List.generate(details.exercises.length, (i) => i + 1),
      );
    },
  );

  test('più WorkoutType supportati, con attrezzatura ampia: successo, '
      'origin FORGE_ENGINE, status READY', () async {
    const types = [
      WorkoutType.fullBody,
      WorkoutType.upperBody,
      WorkoutType.lowerBody,
      WorkoutType.mobility,
      WorkoutType.cardio,
      WorkoutType.recovery,
    ];
    for (final type in types) {
      final result = await useCase(
        GenerateAndPersistForgeWorkoutRequest(
          forgeRequest: request(
            workoutType: type,
            equipment: const {
              'CHAIR',
              'WALL',
              'MAT',
              'BAND',
              'DUMBBELL',
              'STEP',
            },
          ),
          profileId: profileId,
        ),
      );

      expect(result.success, isTrue, reason: '$type: ${result.errors}');
      final details = await workoutRepository.getWorkoutDetails(
        result.workoutId!,
      );
      expect(
        details!.workout.origin,
        WorkoutOrigin.forgeEngine,
        reason: '$type',
      );
      expect(
        details.workout.status,
        WorkoutDefinitionStatus.ready,
        reason: '$type',
      );
    }
  });

  test(
    'CUSTOM: nessuna eccezione, generationFailed, nessuna scrittura',
    () async {
      final result = await useCase(
        GenerateAndPersistForgeWorkoutRequest(
          forgeRequest: request(workoutType: WorkoutType.custom),
          profileId: profileId,
        ),
      );

      expect(result.success, isFalse);
      expect(result.workoutId, isNull);
      expect(
        await workoutRepository.getWorkouts(profileId: profileId),
        isEmpty,
      );
    },
  );

  test('due generazioni distinte creano due schede distinte (sezione 32, '
      'nessuna deduplica)', () async {
    final first = await useCase(
      GenerateAndPersistForgeWorkoutRequest(
        forgeRequest: request(),
        profileId: profileId,
      ),
    );
    final second = await useCase(
      GenerateAndPersistForgeWorkoutRequest(
        forgeRequest: request(),
        profileId: profileId,
      ),
    );

    expect(first.success, isTrue);
    expect(second.success, isTrue);
    expect(first.workoutId, isNot(second.workoutId));
    expect(
      await workoutRepository.getWorkouts(profileId: profileId),
      hasLength(2),
    );
  });
}
