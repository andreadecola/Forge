import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/data/database/app_database.dart';
import 'package:forge/data/repositories/drift_exercise_repository.dart';
import 'package:forge/data/seed/exercise_catalog_seeder.dart';
import 'package:forge/domain/entities/forge_request.dart';
import 'package:forge/domain/entities/workout_enums.dart';
import 'package:forge/domain/services/forge_engine.dart';
import 'package:forge/domain/services/forge_workout_generator.dart';
import 'package:forge/domain/use_cases/generate_forge_workout.dart';

/// Test di integrazione (Milestone 5.2, sezione 73): la generazione
/// completa sul catalogo reale (118 esercizi seedati da
/// `exercises_v1.json`), non su fixture sintetiche — un `GeneratedWorkoutPlan`
/// vero, **non** salvato nel database.
void main() {
  late AppDatabase db;
  late GenerateForgeWorkout useCase;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    final raw = File('assets/data/exercises_v1.json').readAsStringSync();
    await ExerciseCatalogSeeder(db).seedFromString(raw);
    final repository = DriftExerciseRepository(db);
    useCase = GenerateForgeWorkout(
      repository,
      const ForgeEngine(),
      const ForgeWorkoutGenerator(),
    );
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
    'livello 1, FULL_BODY, nessuna attrezzatura, 30 minuti: piano '
    'generato con successo, nessun esercizio duplicato, durata coerente',
    () async {
      final result = await useCase(request());

      expect(result.success, isTrue, reason: '${result.errors}');
      expect(result.plan, isNotNull);
      final plan = result.plan!;
      expect(plan.exercises, isNotEmpty);

      final codes = plan.exercises.map((e) => e.exercise.code).toList();
      expect(codes.toSet().length, codes.length);

      for (final exercise in plan.exercises) {
        expect(exercise.exercise.isActive, isTrue);
        expect(exercise.exercise.minimumLevel, lessThanOrEqualTo(1));
        expect(exercise.workoutExercise.workoutId, 0);
        expect(exercise.workoutExercise.id, isNull);
      }

      final expectedTotal =
          plan.exercises
              .map((e) => e.estimatedDurationSeconds)
              .fold<int>(0, (a, b) => a + b) +
          (plan.exercises.length - 1) * 10;
      expect(plan.estimatedDurationSeconds, expectedTotal);
    },
  );

  test('ordine deterministico su due generazioni identiche', () async {
    final first = await useCase(request());
    final second = await useCase(request());

    expect(
      first.plan!.exercises.map((e) => e.exercise.code).toList(),
      second.plan!.exercises.map((e) => e.exercise.code).toList(),
    );
  });

  test('nessuna eccezione su ogni WorkoutType supportato, con attrezzatura '
      'ampia e diverse durate target', () async {
    for (final type in WorkoutType.values) {
      if (type == WorkoutType.custom) continue;
      for (final duration in [15, 30, 45, 60]) {
        final result = await useCase(
          request(
            workoutType: type,
            targetDurationMinutes: duration,
            equipment: const {
              'CHAIR',
              'WALL',
              'MAT',
              'BAND',
              'DUMBBELL',
              'STEP',
            },
          ),
        );
        expect(
          result.plan,
          isNotNull,
          reason: '$type a $duration minuti: ${result.errors}',
        );
        expect(
          result.plan!.exercises,
          isNotEmpty,
          reason: '$type a $duration minuti',
        );
      }
    }
  });

  test(
    'richiesta CUSTOM: nessuna eccezione, errore esplicito, nessun piano',
    () async {
      final result = await useCase(request(workoutType: WorkoutType.custom));

      expect(result.success, isFalse);
      expect(result.plan, isNull);
      expect(result.errors, isNotEmpty);
    },
  );
}
