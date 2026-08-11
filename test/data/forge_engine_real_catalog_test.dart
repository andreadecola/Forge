import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/data/database/app_database.dart';
import 'package:forge/data/repositories/drift_exercise_repository.dart';
import 'package:forge/data/seed/exercise_catalog_seeder.dart';
import 'package:forge/domain/entities/equipment.dart';
import 'package:forge/domain/entities/forge_request.dart';
import 'package:forge/domain/entities/workout_enums.dart';
import 'package:forge/domain/services/forge_engine.dart';
import 'package:forge/domain/use_cases/evaluate_forge_request.dart';

/// Test di integrazione (Milestone 5.1, sezione 69): il Forge Engine sul
/// catalogo reale (118 esercizi seedati da `exercises_v1.json`), non su
/// fixture sintetiche. Verifica solo che la valutazione sia sensata e
/// deterministica — **non** verifica ancora una scheda generata (arriva
/// con la Milestone 5.2).
void main() {
  late AppDatabase db;
  late EvaluateForgeRequest useCase;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    final raw = File('assets/data/exercises_v1.json').readAsStringSync();
    await ExerciseCatalogSeeder(db).seedFromString(raw);
    final repository = DriftExerciseRepository(db);
    useCase = EvaluateForgeRequest(repository, const ForgeEngine());
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

  test('livello 1, FULL_BODY, nessuna attrezzatura, 30 minuti: nessuna '
      'eccezione, almeno un eleggibile, nessun vincolo HARD violato', () async {
    final result = await useCase(request());

    expect(result.warnings, isEmpty);
    expect(
      result.eligible,
      isNotEmpty,
      reason:
          'il catalogo reale include esercizi di livello 1 senza '
          'attrezzatura (es. mobilità da seduti)',
    );

    for (final evaluation in result.eligible) {
      final exercise = evaluation.candidate.exercise;
      expect(exercise.isActive, isTrue);
      expect(exercise.minimumLevel, lessThanOrEqualTo(1));
      if (exercise.maximumLevel != null) {
        expect(exercise.maximumLevel, greaterThanOrEqualTo(1));
      }
      final missingEquipment = evaluation.candidate.requiredEquipmentCodes
          .where((code) => code != Equipment.noneCode)
          .where((code) => !const <String>{}.contains(code));
      expect(missingEquipment, isEmpty);
      expect(evaluation.score, isNotNull);
      expect(evaluation.estimatedDurationSeconds, isNotNull);
    }

    for (final evaluation in result.excluded) {
      expect(evaluation.eligibility.reasons, isNotEmpty);
    }
  });

  test('ordine deterministico su due valutazioni identiche', () async {
    final first = await useCase(request());
    final second = await useCase(request());

    expect(
      first.eligible.map((e) => e.candidate.exercise.code).toList(),
      second.eligible.map((e) => e.candidate.exercise.code).toList(),
    );
  });

  test('nessuna eccezione anche con attrezzatura ampia e altri WorkoutType '
      'supportati', () async {
    for (final type in WorkoutType.values) {
      if (type == WorkoutType.custom) continue;
      final result = await useCase(
        request(
          workoutType: type,
          equipment: const {'CHAIR', 'WALL', 'MAT', 'BAND', 'DUMBBELL', 'STEP'},
        ),
      );
      expect(result.eligible, isNotEmpty, reason: '$type');
    }
  });
}
